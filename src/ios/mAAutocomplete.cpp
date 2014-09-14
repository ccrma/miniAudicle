//
//  mAAutocomplete.cpp
//  miniAudicle
//
//  Created by Spencer Salazar on 8/28/14.
//
//

#include "mAAutocomplete.h"
#include "chuck_type.h"

using namespace std;

bool skip(const string &name)
{
    if(name == "void" ||
       name == "int" ||
       name == "float" ||
       name == "time" ||
       name == "dur" ||
       name == "complex" ||
       name == "polar" ||
       name == "Class" ||
       name == "Thread" ||
       name == "@function")
        return true;
    return false;
}

bool indexMembers(const string &name)
{
    if(name == "Std" ||
       name == "Machine" ||
       name == "Math" ||
       name == "RegEx")
        return true;
    return false;
}

struct mAAutocompleteNode
{
    mAAutocompleteNode()
    {
        memset(this, 0, sizeof(mAAutocompleteNode));
    }
    
    ~mAAutocompleteNode()
    {
        SAFE_DELETE(completions);
    }

    
    mAAutocompleteNode *getNodeForChar(char c) const
    {
        c = tolower(c);
        if(isalpha(c)) return alpha[c-'a'];
        if(isdigit(c)) return num[c-'0'];
        if(c == '_') return underscore;
        return NULL;
    }
    
    void setNodeForChar(char c, mAAutocompleteNode *node)
    {
        c = tolower(c);
        if(isalpha(c)) alpha[c-'a'] = node;
        if(isdigit(c)) num[c-'0'] = node;
        if(c == '_') underscore = node;
    }
    
    void addCompletion(const string *c)
    {
        if(completions == NULL) completions = new vector<const string *>;
        completions->push_back(c);
    }
    
    mAAutocompleteNode *alpha[26];
    mAAutocompleteNode *num[10];
    mAAutocompleteNode *underscore;
    
    vector<const string *> *completions;
};

mAAutocomplete *mAAutocomplete::autocomplete()
{
    static mAAutocomplete *s_autocomplete = NULL;
    if(s_autocomplete == NULL)
    {
        assert(Chuck_Env::instance()); // need chuck to exist
        s_autocomplete = new mAAutocomplete;
    }
    return s_autocomplete;
}

void mAAutocomplete::test()
{
    const char *testExamples[] = {
        "Sin",
        "Sqr",
        NULL
    };
    
    mAAutocomplete *autocomplete = mAAutocomplete::autocomplete();
    vector<const string *> completions;
    
    for(int i = 0; testExamples[i] != NULL; i++)
    {
        autocomplete->getOpenCompletions(testExamples[i], completions);
        fprintf(stdout, "completions for %s: ", testExamples[i]);
        if(completions.size() == 0)
            fprintf(stdout, "(no completions)");
        else
        {
            for(int j = 0; j < completions.size(); j++)
                fprintf(stdout, "%s ", completions[j]->c_str());
        }
        fprintf(stdout, "\n");
    }
}

bool sortfun_type(Chuck_Type *t1, Chuck_Type *t2) { return t1->name < t2->name; }
bool sortfun(Chuck_Func *f1, Chuck_Func *f2) { return f1->name < f2->name; }

mAAutocomplete::mAAutocomplete()
{
    Chuck_Env * env = Chuck_Env::instance();
    vector<Chuck_Type *> types;
    env->global()->get_types(types);
    sort(types.begin(), types.end(), sortfun_type);
    
    m_tree = new mAAutocompleteNode;
    m_allWords.reserve(types.size());
    
    for(vector<Chuck_Type *>::iterator t = types.begin(); t != types.end(); t++)
    {
        Chuck_Type * type = *t;
        string name = type->name;
        
        if(skip(name)) continue;
        
        string *completion = new string(name);
        m_allWords.push_back(completion);
        
        mAAutocompleteNode *node = m_tree;
        
        for(int i = 0; i < name.length(); i++)
        {
            mAAutocompleteNode *nextNode = node->getNodeForChar(name[i]);
            if(nextNode == NULL)
            {
                nextNode = new mAAutocompleteNode;
                node->setNodeForChar(name[i], nextNode);
            }
            
            // match after 2nd letter
            // match on last letter, but filter out later if exact (case-sensitive) match
            if(i > 1)
                nextNode->addCompletion(completion);
            node = nextNode;
        }
        
        if(indexMembers(name))
        {
            mAAutocompleteNode *memberTree = new mAAutocompleteNode;
            m_memberIndex[name] = memberTree;
            map<string, int> func_names;
            
            vector<Chuck_Func *> funcs;
            type->info->get_funcs(funcs);
            sort(funcs.begin(), funcs.end(), sortfun);

            for(vector<Chuck_Func *>::iterator f = funcs.begin(); f != funcs.end(); f++)
            {
                Chuck_Func * func = *f;
                
                if(func == NULL) continue;
                
                if(func_names.count(func->name))
                    continue;
                func_names[func->name] = 1;
                
                if(func->def->static_decl == ae_key_static)
                {
                    string funcName = S_name(func->def->name);
                    string *memberCompletion = new string(funcName);
                    m_allWords.push_back(memberCompletion);
                    
                    memberTree->addCompletion(memberCompletion);
                    mAAutocompleteNode *node = memberTree;
                    
                    for(int i = 0; i < funcName.length(); i++)
                    {
                        mAAutocompleteNode *nextNode = node->getNodeForChar(funcName[i]);
                        if(nextNode == NULL)
                        {
                            nextNode = new mAAutocompleteNode;
                            node->setNodeForChar(funcName[i], nextNode);
                        }
                        
                        // match on last letter, but filter out later if exact (case-sensitive) match
                        if(i != funcName.length()-1)
                            nextNode->addCompletion(memberCompletion);
                        node = nextNode;
                    }
                }
            }
        }
    }
}

mAAutocomplete::~mAAutocomplete()
{
    SAFE_DELETE(m_tree);
    for(int i = 0; i < m_allWords.size(); i++)
        SAFE_DELETE(m_allWords[i]);
    m_allWords.clear();
}


bool mAAutocomplete::isIdentifierChar(int c)
{
    if(isalnum(c) || c == '_') return true;
    else return false;
}


void mAAutocomplete::getOpenCompletions(const string &word, vector<const string *> &completions)
{
    completions.clear();
    
    mAAutocompleteNode *node = m_tree;
    for(int i = 0; i < word.length() && node != NULL; i++)
        node = node->getNodeForChar(word[i]);
    
    if(node != NULL && node->completions != NULL)
        completions = *node->completions;
    
    // ignore singular completions that match exactly
    if(completions.size() == 1 && *completions[0] == word)
        completions.clear();
}

void mAAutocomplete::getMemberCompletions(const std::string &pre, const std::string &post, std::vector<const std::string *> &completions)
{
    completions.clear();
    
    if(m_memberIndex.count(pre))
    {
        mAAutocompleteNode *node = m_memberIndex[pre];
        for(int i = 0; i < post.length() && node != NULL; i++)
            node = node->getNodeForChar(post[i]);
        
        if(node != NULL && node->completions != NULL)
            completions = *node->completions;
        
        // ignore singular completions that match exactly
        if(completions.size() == 1 && *completions[0] == post)
            completions.clear();
    }
}

