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
        autocomplete->getCompletions(testExamples[i], completions);
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

mAAutocomplete::mAAutocomplete()
{
    Chuck_Env * env = Chuck_Env::instance();
    vector<Chuck_Type *> types;
    env->global()->get_types(types);
    
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
            // but dont match on last letter
            if(i > 1 && i != name.length()-1)
                nextNode->addCompletion(completion);
            node = nextNode;
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


void mAAutocomplete::getCompletions(const string &word, vector<const string *> &completions)
{
    completions.clear();
    
    mAAutocompleteNode *node = m_tree;
    for(int i = 0; i < word.length() && node != NULL; i++)
        node = node->getNodeForChar(word[i]);
    
    if(node != NULL && node->completions != NULL)
        completions = *node->completions;
}

