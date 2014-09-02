//
//  mAAutocomplete.h
//  miniAudicle
//
//  Created by Spencer Salazar on 8/28/14.
//
//

#ifndef __miniAudicle__mAAutocomplete__
#define __miniAudicle__mAAutocomplete__

#include <string>
#include <vector>
#include <map>

struct mAAutocompleteNode;

class mAAutocomplete
{
public:
    static mAAutocomplete *autocomplete();
    static void test();
    
    bool isIdentifierChar(int c);
    void getOpenCompletions(const std::string &word, std::vector<const std::string *> &completions);
    void getMemberCompletions(const std::string &pre, const std::string &post, std::vector<const std::string *> &completions);
    
protected:
    mAAutocomplete();
    ~mAAutocomplete();
    
    mAAutocompleteNode *m_tree;
    std::map<std::string, mAAutocompleteNode *> m_memberIndex;
    std::vector<const std::string*> m_allWords;
};

#endif /* defined(__miniAudicle__mAAutocomplete__) */
