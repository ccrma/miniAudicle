//
//  mAAutocomplete.h
//  miniAudicle
//
//  Created by Spencer Salazar on 8/28/14.
//
//

#ifndef __miniAudicle__mAAutocomplete__
#define __miniAudicle__mAAutocomplete__

#import <string>
#import <vector>

struct mAAutocompleteNode;

class mAAutocomplete
{
public:
    static mAAutocomplete *autocomplete();
    static void test();
    
    bool isIdentifierChar(int c);
    void getCompletions(const std::string &word, std::vector<const std::string *> &completions);
    
protected:
    mAAutocomplete();
    ~mAAutocomplete();
    
    mAAutocompleteNode *m_tree;
    std::vector<const std::string*> m_allWords;
};

#endif /* defined(__miniAudicle__mAAutocomplete__) */
