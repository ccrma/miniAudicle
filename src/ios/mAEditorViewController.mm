//
//  mAEditorViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import "mAEditorViewController.h"
#import "mATextView.h"
#import "miniAudicle.h"
#import "mAChucKController.h"
#import "mAFileViewController.h"
#import "mADetailItem.h"
#import "mAAppDelegate.h"
#import "mADocumentManager.h"
#import "mAAutocomplete.h"
#import "mATextCompletionView.h"
#import "mASocialShareViewController.h"
#import "mAAnalytics.h"

#import "NSString+NSString_Lines.h"
#import "NSString+STLString.h"
#import "UIAlert.h"
#import "UIColor+iOS7BlueColor.h"


@interface NSString (CharacterEnumeration)

/**
 * Enumerate characters of the string with the specified block.
 * @param block A block taking the current position in the string and the character at that
 *              position. This should return YES to continue enumeration or NO to stop it.
 * @param fromPosition The position in the string to start at.
 * @param reverse Whether to enumerate in reverse or forward direction.
 */
- (void)enumerateCharacters:(BOOL (^)(int pos, unichar c))block fromPosition:(NSInteger)index reverse:(BOOL)reverse;

/**
 * Enumerate characters of the string with the specified block.
 * @param block A block taking the current position in the string and the character at that
 *              position. This should return YES to continue enumeration or NO to stop it.
 */
- (void)enumerateCharacters:(BOOL (^)(int pos, unichar c))block;

@end

@interface UITextView (Ranges)

- (UITextRange *)textRangeFromRange:(NSRange)range;
- (UITextPosition *)textPositionFromIndex:(NSInteger)index;
//- (NSRange)rangeFromTextRange:(UITextRange *)textRange;

@end


@interface mAEditorViewController ()
{
    NSRange _errorRange;
    NSRange _completionRange;
    BOOL _lockAutoFormat;
    BOOL _dirty;
    CGSize _singleCharSize;
    mATextCompletionView *_textCompletionView;
    
    IBOutlet UILabel *_shredCountLabel;
    IBOutlet UIButton *_addButton;
    IBOutlet UIButton *_replaceButton;
    IBOutlet UIButton *_removeButton;
}

@property (strong, nonatomic) mATextView * textView;
@property (strong, nonatomic) UIView * otfToolbar;

@property (strong, nonatomic) UIPopoverController * popover;
@property (strong, nonatomic) mATitleEditorController * titleEditor;

- (void)setup;
- (NSDictionary *)defaultTextAttributes;
- (NSDictionary *)errorTextAttributes;
- (void)configureView;

- (void)showCompletions:(NSArray *)completions forTextRange:(NSRange)range;
- (void)hideCompletions;
- (void)completeText:(id)sender;
- (int)indentationForTextPosition:(NSUInteger)position
                     bracketLevel:(int)bracketLevel
                       parenLevel:(int)parenLevel;
- (NSInteger)tabSize;

@end

@implementation mAEditorViewController

- (void)setShowOTFToolbar:(BOOL)showOTFToolbar
{
    if(!showOTFToolbar)
    {
        [self.otfToolbar removeFromSuperview];
        self.textView.frame = self.view.bounds;
    }
    else
    {
        [self.view addSubview:self.otfToolbar];
        CGRect rect = self.view.bounds;
        rect.origin.y += self.otfToolbar.frame.size.height;
        rect.size.height -= self.otfToolbar.frame.size.height;
        self.textView.frame = rect;
    }
}

- (BOOL)showOTFToolbar
{
    return self.otfToolbar.superview != nil;
}

- (NSDictionary *)defaultTextAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [UIFont fontWithName:@"Menlo" size:14], NSFontAttributeName,
            nil];
}

- (NSDictionary *)errorTextAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5], NSBackgroundColorAttributeName,
            nil];
}

- (void)setDetailItem:(id)newDetailItem
{
    if(_detailItem != newDetailItem)
    {
        if(_detailItem)
        {
            // save text
            [self saveScript];
            [[mAAppDelegate appDelegate] saveScripts];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:mADetailItemDeletedNotification
                                                          object:_detailItem];
        }
        
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
        
        if(_detailItem)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(detailItemWasDeleted:)
                                                         name:mADetailItemDeletedNotification
                                                       object:_detailItem];
        }
    }
}

- (void)setup
{
    self.titleButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(editTitle:)];
    _lockAutoFormat = NO;
    _dirty = NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _errorRange = NSMakeRange(NSNotFound, 0);
    
    self.textView.font = [UIFont fontWithName:@"Menlo" size:14];
    
    self.textView.inputAccessoryView = self.keyboardAccessory.view;
    self.keyboardAccessory.delegate = self;
    
    self.textView.textStorage.delegate = self;
    
    _textCompletionView = [[mATextCompletionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [_textCompletionView addTarget:self action:@selector(completeText:) forControlEvents:UIControlEventTouchUpInside];
    
    _singleCharSize = [@" " sizeWithAttributes:[self defaultTextAttributes]];
    
    // remove undo/redo/clipboard toolbar
    // iOS 9 only
    if([self.textView respondsToSelector:@selector(inputAssistantItem)])
    {
        self.textView.inputAssistantItem.leadingBarButtonGroups = @[];
        self.textView.inputAssistantItem.trailingBarButtonGroups = @[];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self configureView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[mAAnalytics instance] editorScreen];
    
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    // Update the user interface for the detail item.
    [self configureTitle:self.detailItem.title editable:self.detailItem.isUser];
    
    if(self.detailItem)
    {
        self.textView.editable = YES;
        _addButton.enabled = YES;
        _replaceButton.enabled = YES;
        _removeButton.enabled = YES;
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.detailItem.text
                                                                                 attributes:[self defaultTextAttributes]];
        [[mASyntaxHighlighting sharedHighlighter] colorString:text range:NSMakeRange(0, [text length]-1) colorer:nil];
        
        _lockAutoFormat = YES;
        self.textView.attributedText = text;
        _lockAutoFormat = NO;
    }
    else
    {
        self.textView.editable = NO;
        _addButton.enabled = NO;
        _replaceButton.enabled = NO;
        _removeButton.enabled = NO;
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@""
                                                                                 attributes:[self defaultTextAttributes]];

        _lockAutoFormat = YES;
        self.textView.attributedText = text;
        _lockAutoFormat = NO;
    }
    
    self.textView.errorMessage = nil;
    self.textView.errorLine = -1;
    
    _dirty = NO;
    
//    if(self.detailItem.numShreds > 0)
//        _shredCountLabel.text = [NSString stringWithFormat:@"%lu", self.detailItem.numShreds];
//    else
//        _shredCountLabel.text = @"";
    _shredCountLabel.text = @"";
}

- (void)configureTitle:(NSString *)title editable:(BOOL)editable;
{
    if(title && [title length])
    {
        self.titleButton.title = title;
        if(editable)
        {
            self.titleButton.enabled = YES;
            // set default attributes (blue text color)
            [self.titleButton setTitleTextAttributes:@{ }
                                            forState:UIControlStateNormal];
        }
        else
        {
            self.titleButton.enabled = NO;
            // set black text color
            [self.titleButton setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor], }
                                            forState:UIControlStateNormal];
        }
    }
    else
    {
        self.titleButton.title = @"";
        self.titleButton.enabled = NO;
        [self.titleButton setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor], }
                                        forState:UIControlStateNormal];
    }
}

- (void)detailItemWasDeleted:(NSNotification *)n
{
    self.detailItem = nil;
}

- (NSInteger)tabSize
{
    return 4;
}


#pragma mark - IBActions

- (void)saveScript
{
    self.detailItem.text = self.textView.text;
    [self.detailItem save];
    _dirty = NO;
}


- (IBAction)addShred
{
    if(self.detailItem == nil) return;
    
    [[mAAnalytics instance] editAddButton:self.detailItem.uuid];
    
    if(_dirty)
        [self saveScript];
    
    std::string code = [self.textView.text UTF8String];
    std::string name = [self.detailItem.title UTF8String];
    std::string filepath;
    if(self.detailItem.path && [self.detailItem.path length])
        filepath = [self.detailItem.path UTF8String];
    vector<string> args;
    t_CKUINT shred_id;
    std::string output;
    
    t_OTF_RESULT otf_result = [mAChucKController chuckController].ma->run_code(code, name, args, filepath,
                                                                               self.detailItem.docid,
                                                                               shred_id, output);
    
    if( otf_result == OTF_SUCCESS )
    {
//        if([self.windowController currentViewController] == self)
//            [[text_view textView] animateAdd];
        self.textView.errorLine = -1;
        self.textView.errorMessage = nil;
        [self.textView animateAdd];
        
//        self.detailItem.numShreds = self.detailItem.numShreds+1;
//        if(self.detailItem.numShreds > 0)
//            _shredCountLabel.text = [NSString stringWithFormat:@"%lu", self.detailItem.numShreds];
//        else
//            _shredCountLabel.text = @"";
    }
    else if( otf_result == OTF_VM_TIMEOUT )
    {
//        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
//        [mac setLockdown:YES];
    }
    else if( otf_result == OTF_COMPILE_ERROR )
    {
        int error_line;
        std::string result;
        if( [mAChucKController chuckController].ma->get_last_result( self.detailItem.docid, NULL, &result, &error_line ) )
        {
            self.textView.errorLine = error_line;
            self.textView.errorMessage = [[NSString stringWithUTF8String:result.c_str()] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
//        if([self.windowController currentViewController] == self)
//            [[text_view textView] animateError];
        [self.textView animateError];
    }
    else
    {
//        if([self.windowController currentViewController] == self)
//            [[text_view textView] animateError];
//
//        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
        [self.textView animateError];
    }
}


- (IBAction)replaceShred
{
    if(self.detailItem == nil) return;
    
    [[mAAnalytics instance] editReplaceButton:self.detailItem.uuid];

    if(_dirty)
        [self saveScript];

    std::string code = [self.textView.text UTF8String];
    std::string name = [self.detailItem.title UTF8String];
    std::string filepath;
    if(self.detailItem.path && [self.detailItem.path length])
        filepath = [self.detailItem.path UTF8String];
    vector<string> args;
    t_CKUINT shred_id;
    std::string output;
    
    t_OTF_RESULT otf_result = [mAChucKController chuckController].ma->replace_code(code, name, args, filepath,
                                                                                   self.detailItem.docid,
                                                                                   shred_id, output);
    if( otf_result == OTF_SUCCESS )
    {
//        if([self.windowController currentViewController] == self)
//            [[text_view textView] animateAdd];
        self.textView.errorLine = -1;
        self.textView.errorMessage = nil;
        [self.textView animateReplace];
    }
    else if( otf_result == OTF_VM_TIMEOUT )
    {
//        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
//        [mac setLockdown:YES];
    }
    else if( otf_result == OTF_COMPILE_ERROR )
    {
        int error_line;
        std::string result;
        if( [mAChucKController chuckController].ma->get_last_result( self.detailItem.docid, NULL, &result, &error_line ) )
        {
            self.textView.errorLine = error_line;
            self.textView.errorMessage = [[NSString stringWithUTF8String:result.c_str()] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        [self.textView animateError];
//        if([self.windowController currentViewController] == self)
//            [[text_view textView] animateError];
    }
    else
    {
//        if([self.windowController currentViewController] == self)
//            [[text_view textView] animateError];
//
//        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
        [self.textView animateError];
    }
}


- (IBAction)removeShred
{
    if(self.detailItem == nil) return;
    
    [[mAAnalytics instance] editRemoveButton:self.detailItem.uuid];
    
    if(_dirty)
        [self saveScript];
    
    t_CKUINT shred_id;
    std::string output;
    
    t_OTF_RESULT result = [mAChucKController chuckController].ma->remove_code(self.detailItem.docid,
                                                                              shred_id, output);
    
    if(result == OTF_SUCCESS)
    {
        [self.textView animateRemove];
        
//        self.detailItem.numShreds = self.detailItem.numShreds-1;
//        if(self.detailItem.numShreds > 0)
//            _shredCountLabel.text = [NSString stringWithFormat:@"%lu", self.detailItem.numShreds];
//        else
//            _shredCountLabel.text = @"";
    }
    else if(result == OTF_VM_TIMEOUT)
    {
    }
    else
    {
        [self.textView animateError];
    }
}

- (IBAction)removeLastShred
{
    std::string output;
    t_OTF_RESULT result = [mAChucKController chuckController].ma->removelast(self.detailItem.docid, output);
    
    if(result == OTF_SUCCESS)
    {
    }
    else if(result == OTF_VM_TIMEOUT)
    {
    }
    else
    {
        [self.textView animateError];
    }
}

- (IBAction)removeAllShreds
{
    std::string output;
    t_OTF_RESULT result = [mAChucKController chuckController].ma->removeall(self.detailItem.docid, output);
    
    if(result == OTF_SUCCESS)
    {
    }
    else if(result == OTF_VM_TIMEOUT)
    {
    }
    else
    {
        [self.textView animateError];
    }
}

- (IBAction)editTitle:(id)sender
{
    [[mAAnalytics instance] editTitleButton:self.detailItem.uuid];
    
    if(self.popover == nil)
    {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:self.titleEditor];
    }
    
    self.titleEditor.editedTitle = self.detailItem.title;
    self.titleEditor.delegate = self;
    self.popover.delegate = self;
    
    [self.popover presentPopoverFromBarButtonItem:self.titleButton
                         permittedArrowDirections:UIPopoverArrowDirectionUp
                                         animated:YES];
}


- (void)titleEditorDidConfirm:(mATitleEditorController *)titleEditor
{
    [self.popover dismissPopoverAnimated:YES];
    
    [self saveScript];
    
    //self.detailItem.title = self.titleEditor.editedTitle;
    NSError *error;
    [[mADocumentManager manager] renameItem:self.detailItem
                                         to:self.titleEditor.editedTitle
                                      error:&error];
    if(error != nil)
    {
        UIAlertMessage2a(@"The file could not be renamed.",
                         error.localizedFailureReason,
                         @"Cancel", ^{
                             [self.textView becomeFirstResponder];
                         },
                         @"Choose Another Name", ^{
                             [self editTitle:nil];
                         });
    }
    else
    {
        [self configureView];
        [self.textView becomeFirstResponder];
    }
}


- (void)titleEditorDidCancel:(mATitleEditorController *)titleEditor
{
    [self.popover dismissPopoverAnimated:YES];
    
    [self.textView becomeFirstResponder];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.textView becomeFirstResponder];
}


#pragma mark - mAInteractionModeController

- (NSArray<NSString *> *)menuItems
{
    if(self.detailItem.isUser)
        return @[ @"Rename", @"Duplicate", @"Share" ];
    else
        return @[ @"Duplicate" ];
}

- (void)handleMenuItem:(NSInteger)item
{
    NSLog(@"menuItem: %@", self.menuItems[item]);
    
    if(self.detailItem.isUser && item == 2) // share
    {
        mASocialShareViewController *shareView = [mASocialShareViewController new];
        shareView.script = self.detailItem;
        [self presentViewController:shareView animated:YES completion:^{}];
    }
}

#pragma mark - NSTextStorageDelegate

- (void)showCompletions:(NSArray *)completions forTextRange:(NSRange)range
{
    _textCompletionView.completions = completions;
    _textCompletionView.textAttributes = [self defaultTextAttributes];
    [_textCompletionView sizeToFit];
    
    // default value is usually not needed, but set here to simply logic
    CGRect textRect = CGRectMake(0, _singleCharSize.height+1, _singleCharSize.width, _singleCharSize.height);
    // usually first two cases are sufficient
    if(range.length == 0 && range.location > 0)
    {
        textRect = [self.textView firstRectForRange:[self.textView textRangeFromRange:NSMakeRange(range.location-1, 1)]];
        textRect.origin.x += _singleCharSize.width;
    }
    else if(range.location+1 < [self.textView.textStorage length])
        textRect = [self.textView firstRectForRange:[self.textView textRangeFromRange:NSMakeRange(range.location, 1)]];
    else
    {
        // this occurs for member completions at the end of the file
        if(range.location == [self.textView.textStorage length])
        {
            if(range.location > 1)
            {
                textRect = [self.textView firstRectForRange:[self.textView textRangeFromRange:NSMakeRange(range.location-2, 1)]];
                textRect.origin.x += _singleCharSize.width*2;
            }
            // else use default
        }
        else if(range.location > 0)
        {
            textRect = [self.textView firstRectForRange:[self.textView textRangeFromRange:NSMakeRange(range.location-1, 1)]];
            textRect.origin.x += _singleCharSize.width;
        }
        // else use default
    }
    CGRect frame = _textCompletionView.frame;
    frame.origin.x = textRect.origin.x-8;
    frame.origin.y = textRect.origin.y+textRect.size.height+4;
    _textCompletionView.frame = frame;
    
    if(_textCompletionView.superview == nil)
    {
        _textCompletionView.alpha = 0;
        [self.textView addSubview:_textCompletionView];
        
        [UIView animateWithDuration:1-(G_RATIO-1)
                            animations:^{
                                _textCompletionView.alpha = 1;
                            }];
    }
}

- (void)hideCompletions
{
    if(_textCompletionView.superview != nil)
    {
        [UIView animateWithDuration:1-(G_RATIO-1)
                         animations:^{
                         _textCompletionView.alpha = 0;
                         } completion:^(BOOL finished) {
                             if(finished) [_textCompletionView removeFromSuperview];
                         }];
    }
}

- (void)completeText:(id)sender
{
    NSString *selectedCompletion = _textCompletionView.selectedCompletion;
    
    if(selectedCompletion)
    {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:selectedCompletion
                                                                                 attributes:[self defaultTextAttributes]];
        [[mASyntaxHighlighting sharedHighlighter] colorString:text range:NSMakeRange(0, [text length]-1) colorer:nil];
        [self.textView.textStorage replaceCharactersInRange:_completionRange withAttributedString:text];
        
        NSRange selectedRange = self.textView.selectedRange;
        selectedRange.location += text.length-_completionRange.length;
        self.textView.selectedRange = selectedRange;
        
        [self hideCompletions];
    }
}

- (int)indentationForTextPosition:(NSUInteger)position
                     bracketLevel:(int)bracketLevel
                       parenLevel:(int)parenLevel
{
    NSString *text = self.textView.text;
    
    // determine whitespace for this line by scanning previous line
    
    // backward search
    // skip first newline (newline immediately preceding this line)
    
    __block signed int brace1Count = 0;
    __block int newline1Index = -1; // = [text indexOfPreviousNewline:position];
    [text enumerateCharacters:^BOOL(int pos, unichar c) {
        if(c == '\n' || c == 'r')
        {
            newline1Index = pos;
            return NO;
        }
        else if(c == '{') brace1Count++;
        else if(c == '}') brace1Count--;
        
        return YES;
    } fromPosition:position-1 reverse:YES];
    
    if(newline1Index == -1 || newline1Index == 0) return 0;
    
    // find next newline; count whitespace after it
    int newline2Index = -1;
    signed int braceCount = 0;
    signed int parenCount = parenLevel;
    signed int bracketCount = bracketLevel;
    int innerMostOpenBracketOrParen = -1;
    for(int i = newline1Index-1; i >= 0; i--)
    {
        unichar c = [text characterAtIndex:i];
        if(c == '\n' || c == '\r')
        {
            newline2Index = i;
            break;
        }
        if(c == '{') braceCount++;
        if(c == '}') braceCount--;
        if(c == '(') parenCount++;
        if(c == ')') parenCount--;
        if(c == '[') bracketCount++;
        if(c == ']') bracketCount--;
        
        // hanging open paren indent
        // indent to this level instead of regular indent
        if(parenCount > 0 && innerMostOpenBracketOrParen == -1) innerMostOpenBracketOrParen = i;
        if(bracketCount > 0 && innerMostOpenBracketOrParen == -1) innerMostOpenBracketOrParen = i;
    }
    
    if(innerMostOpenBracketOrParen != -1)
        return ::max(0, innerMostOpenBracketOrParen - newline2Index);
    if(parenCount < 0 || bracketCount < 0)
    {
        // close paren - adjust indent based on previous line
        if(newline2Index > 0)
            return [self indentationForTextPosition:newline2Index+1 bracketLevel:bracketCount parenLevel:parenCount];
        else
            return 0;
    }
    
    int addSpace = (braceCount>0 ? braceCount : 0) * self.tabSize;
    int removeSpace = (brace1Count<0 ? brace1Count : 0) * self.tabSize;
    
    if(newline2Index == -1) return addSpace;
    
    int previousLineSpace = 0;
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    for(int i = newline2Index+1; [set characterIsMember:[text characterAtIndex:i]]; i++)
    {
        unichar c = [text characterAtIndex:i];
        if(c == ' ') previousLineSpace++;
        else if(c == '\t') previousLineSpace += 4;
    }
    
    return ::max(0, previousLineSpace + addSpace + removeSpace);
}

- (void)textStorage:(NSTextStorage *)textStorage
 willProcessEditing:(NSTextStorageEditActions)editedMask
              range:(NSRange)editedRange
     changeInLength:(NSInteger)delta
{
    if(_lockAutoFormat)
        return;
    
    NSLog(@"textStorageWillProcessEditing %li:%li ∂:%li",
          editedRange.location, editedRange.length, delta );
    
    if(editedRange.length == 0)
        [self textStorageRemovedText:textStorage range:editedRange];
    else if(editedRange.length == delta)
        [self textStorageAddedText:textStorage range:editedRange];
    else
        [self textStorageReplacedText:textStorage range:editedRange];
}

- (void)textStorageAddedText:(NSTextStorage *)textStorage
                       range:(NSRange)editedRange
{
    // any characters are inserted before the editing is processed
    
    // scan for newline or close brace
    // add/remove indentation as needed
    int charDelta = 0;
    for(int i = 0; i < editedRange.length && editedRange.location + i < [textStorage length]; i++)
    {
        NSUInteger index = editedRange.location + i;
        unichar c = [[textStorage string] characterAtIndex:index];
        if(c == '\n' || c == '\r')
        {
            int nSpaces = [self indentationForTextPosition:index+1 bracketLevel:0 parenLevel:0];
            //            NSLog(@"%d spaces", nSpaces);
            if(nSpaces != 0)
            {
                charDelta += nSpaces;
                NSString *spaces = [@"" stringByPaddingToLength:nSpaces
                                                     withString:@" "
                                                startingAtIndex:0];
                // TODO: replace spaces after \n instead of blind insert
                __block NSUInteger endSpacePos = [textStorage length];
                [[textStorage string] enumerateCharacters:^BOOL(int pos, unichar c) {
                    if(c == ' ' || c == '\t') return YES;
                    endSpacePos = pos;
                    return NO;
                } fromPosition:index+1 reverse:NO];
                [textStorage replaceCharactersInRange:NSMakeRange(index+1, endSpacePos-(index+1)) withString:spaces];
                i += nSpaces;
                index += nSpaces;
                editedRange.length += nSpaces;
            }
            
            // check next character, if its past the edited range
            if(index+1 < [textStorage length] && i+1 >= editedRange.length)
            {
                unichar cc = [[textStorage string] characterAtIndex:index+1];
                if(cc == '}')
                {
                    // add another newline
                    [textStorage replaceCharactersInRange:NSMakeRange(index+1, 0) withString:@"\n"];
                    
                    // add spaces
                    int nSpaces2 = ::max<NSInteger>(0, nSpaces-self.tabSize);
                    NSString *spaces = [@"" stringByPaddingToLength:nSpaces2
                                                         withString:@" "
                                                    startingAtIndex:0];
                    [textStorage replaceCharactersInRange:NSMakeRange(index+2, 0) withString:spaces];
                }
            }
        }
        else if(c == '}')
        {
            // remove spaces
            int nSpaces = [self indentationForTextPosition:index+1 bracketLevel:0 parenLevel:0];
            //nSpaces = ::max(0, nSpaces-4);
            //            int newlineIndexPlus1 = [[textStorage string] indexOfPreviousNewline:index]+1;
            //
            NSRange wsRange = [[textStorage string] rangeOfLeadingWhitespace:index];
            charDelta += nSpaces-wsRange.length;
            NSString *spaces = [@"" stringByPaddingToLength:nSpaces
                                                 withString:@" "
                                            startingAtIndex:0];
            //            [textStorage replaceCharactersInRange:NSMakeRange(newlineIndexPlus1, index-newlineIndexPlus1) withString:spaces];
            [textStorage replaceCharactersInRange:wsRange withString:spaces];
            editedRange.location += nSpaces-wsRange.length;
        }
    }
    
    NSRange selectedRange = self.textView.selectedRange;
    if(charDelta != 0)
    {
        //        NSLog(@"charDelta: %d", charDelta);
        if(selectedRange.length == 0)
            self.textView.selectedRange = NSMakeRange(selectedRange.location+charDelta, 0);
        else
            self.textView.selectedRange = NSMakeRange(selectedRange.location, selectedRange.length+charDelta);
    }
}

- (void)textStorageReplacedText:(NSTextStorage *)textStorage
                          range:(NSRange)editedRange
{
    
}

- (void)textStorageRemovedText:(NSTextStorage *)textStorage
                         range:(NSRange)editedRange
{
    
}

- (void)textStorage:(NSTextStorage *)textStorage
  didProcessEditing:(NSTextStorageEditActions)editedMask
              range:(NSRange)editedRange
     changeInLength:(NSInteger)delta
{
    if(_lockAutoFormat)
        return;
    
    // syntax highlighting and autocomplete is done after the editing is processed
    
    NSUInteger start_index, line_end_index, contents_end_index;
    [[textStorage string] getLineStart:&start_index
                                   end:&line_end_index
                           contentsEnd:&contents_end_index
                              forRange:editedRange];
    
    [[mASyntaxHighlighting sharedHighlighter] colorString:textStorage
                                                    range:NSMakeRange( start_index, contents_end_index - start_index )
                                                  colorer:nil];
    
    // scan for autocomplete
    BOOL hasCompletions = NO;
    if(editedRange.length == 1 && delta > 0)
    {
        mAAutocomplete *autocomplete = mAAutocomplete::autocomplete();
        NSString *text = [textStorage string];
        
        __block int wordPos = 0;
        __block int memberOfPos = 0;
        __block BOOL hasWord = NO;
        __block BOOL hasMember = NO;
        
        [text enumerateCharacters:^BOOL(int pos, unichar c) {
            if(autocomplete->isIdentifierChar(c))
            {
                if(pos == 0)
                {
                    hasWord = YES;
                    wordPos = 0;
                }
                
                return YES;
            }
            
            // member completion
            if(c == '.')
            {
                if(pos >= 1)
                {
                    // determine member word
                    [text enumerateCharacters:^BOOL(int pos2, unichar c2) {
                        if(autocomplete->isIdentifierChar(c2))
                        {
                            if(pos2 == 0)
                            {
                                wordPos = pos+1;
                                memberOfPos = 0;
                                hasMember = YES;
                            }
                            
                            return YES;
                        }
                        
                        if(pos2 != pos)
                        {
                            wordPos = pos+1;
                            memberOfPos = pos2+1;
                            hasMember = YES;
                        }
                        
                        return NO;
                    } fromPosition:pos-1 reverse:YES];
                }
            }
            // "open" completion
            else if(pos != editedRange.location &&
                    (c != ':' && c != '.'))
            {
                wordPos = pos+1;
                hasWord = YES;
            }
            
            return NO;
            
        } fromPosition:editedRange.location reverse:YES];
        
        if(hasWord)
        {
            vector<const string *> completions;
            NSString *word = [text substringWithRange:NSMakeRange(wordPos, editedRange.location-wordPos+1)];
            autocomplete->getOpenCompletions([word stlString], completions);
            
            if(completions.size())
            {
                _completionRange = NSMakeRange(wordPos, editedRange.location-wordPos+1);
                
                NSMutableArray *completions2 = [NSMutableArray new];
                for(int i = 0; i < completions.size(); i++)
                    [completions2 addObject:[NSString stringWithSTLString:*completions[i]]];
                hasCompletions = YES;
                
                [self showCompletions:completions2 forTextRange:_completionRange];
            }
        }
        else if(hasMember)
        {
            vector<const string *> completions;
            NSString *pre = [text substringWithRange:NSMakeRange(memberOfPos, wordPos-memberOfPos-1)];
            NSString *post = [text substringWithRange:NSMakeRange(wordPos, editedRange.location-wordPos+1)];
            autocomplete->getMemberCompletions([pre stlString], [post stlString], completions);
            
//            fprintf(stdout, "[%s.%s]: ", [pre UTF8String], [post UTF8String]);
            
            if(completions.size())
            {
//                for(int i = 0; i < completions.size(); i++)
//                    fprintf(stdout, "%s ", completions[i]->c_str());
                
                _completionRange = NSMakeRange(wordPos, editedRange.location-wordPos+1);
//                fprintf(stdout, "%d:%d", _completionRange.location, _completionRange.length);
                
                NSMutableArray *completions2 = [NSMutableArray new];
                for(int i = 0; i < completions.size(); i++)
                    [completions2 addObject:[NSString stringWithSTLString:*completions[i]]];
                
                hasCompletions = YES;
                [self showCompletions:completions2 forTextRange:_completionRange];
            }
            
//            fprintf(stdout, "\n");
//            fflush(stdout);
        }
    }
    if(!hasCompletions)
        [self hideCompletions];
}


#pragma mark - mAKeyboardAccessoryDelegate

- (void)keyPressed:(NSString *)chars selectionOffset:(NSInteger)offset
{
    [self.textView insertText:chars];
    
    if(offset != 0)
    {
        NSRange selectionRange = self.textView.selectedRange;
        selectionRange.location = ::min<int>(::max<int>(selectionRange.location+offset, 0), self.textView.text.length-selectionRange.length);
        self.textView.selectedRange = selectionRange;
    }
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText
{
    // override/disable automatic spacing of .
    if([replacementText isEqualToString:@". "] && range.location != [textView selectedRange].location)
        return NO;
    
    NSString *text = [textView text];
//    NSString *textToChange = [[textView text] substringWithRange:range];
    
    // deletion of a character
    if([replacementText length] == 0 && range.length == 1)
    {
        unichar deletedChar = [text characterAtIndex:range.location];
        
        // if there are any more characters after the deleted one
        if(range.location+1 < [text length])
        {
            unichar nextChar = [text characterAtIndex:range.location+1];
            // if the deleted character is { and the next character is a } delete that too
            if(deletedChar == '{' && nextChar == '}')
                [[textView textStorage] deleteCharactersInRange:NSMakeRange(range.location+1, 1)];
            // if the deleted character is [ and the next character is a ] delete that too
            else if(deletedChar == '[' && nextChar == ']')
                [[textView textStorage] deleteCharactersInRange:NSMakeRange(range.location+1, 1)];
            // if the deleted character is ( and the next character is a ) delete that too
            else if(deletedChar == '(' && nextChar == ')')
                [[textView textStorage] deleteCharactersInRange:NSMakeRange(range.location+1, 1)];
        }

        // delete to next tab stop in leading whitespace
        if(deletedChar == ' ')
        {
            // count backwards amount of whitespace
            // if a tab is found before a tabs worth of space, delete to that tab
            __block int nSpaces = 0;
            __block BOOL isLeading = NO;
            [text enumerateCharacters:^BOOL(int pos, unichar c) {
                if(c == ' ') { nSpaces++; return YES; }
                else if(c == '\n' || c == '\r') { isLeading = YES; return NO; }
                else { return NO; }
            } fromPosition:range.location reverse:YES];
            
            if(isLeading)
            {
                // round to next lowest multiple of tab size
                int tabSize = self.tabSize;
                int remainder = nSpaces % tabSize;
                int nTargetSpaces = remainder ? nSpaces-remainder : nSpaces-tabSize;
                int spacesToDelete = nSpaces - nTargetSpaces;
                if(spacesToDelete > 0)
                {
                    NSLog(@"deleting leading whitespace");
                    // move cursor
                    NSRange selectionRange = self.textView.selectedRange;
                    selectionRange.location -= spacesToDelete;
                    self.textView.selectedRange = selectionRange;
                    // delete
                    [[textView textStorage] deleteCharactersInRange:NSMakeRange(range.location-spacesToDelete+1, spacesToDelete)];
//                    [[textView textStorage] addAttribute:NSBackgroundColorAttributeName
//                                                   value:[UIColor redColor]
//                                                   range:NSMakeRange(range.location-spacesToDelete+1, spacesToDelete)];
                    return NO;
                }
            }
        }

        if(range.location+2 < [text length])
        {
            // if the deleted character is \n and the next characters are \n [whitespace]* }
            // then delete the 2nd \n, whitespace, and }
            if([text characterAtIndex:range.location] == '\n')
            {
                __block NSRange delRange = NSMakeRange(range.location+1, 0);
                __block int numNewline = 0;
                [text enumerateCharacters:^BOOL(int pos, unichar c) {
                    switch(c)
                    {
                        case '\n':
                        case '\r':
                            numNewline++;
                            if(numNewline >= 2)
                                // if theres more than 1 newline, dont delete
                                return NO;
                            else
                                return YES;
                        case ' ':
                        case '\t':
                            return YES;
                        case '}':
                            delRange.length = ::max<NSInteger>(0, pos-1-range.location);
                            return NO;
                        default:
                            return NO;
                    }
                } fromPosition:range.location+1 reverse:NO];
                
                if(delRange.length)
                {
                    NSLog(@"deleting trailing newline/space before close brace");
                    [[textView textStorage] deleteCharactersInRange:delRange];
                }
            }
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [[mAAnalytics instance] editEditScript:self.detailItem.uuid];
    _dirty = YES;
}


#pragma mark - UIKeyboardWillShowNotification / UIKeyboardWillHideNotification

- (void)keyboardWillShow:(NSNotification *)n
{
//    NSLogFun();
    if(self.isPlayerEditor)
        return;
    
    CGRect kbRect = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:self.view.window];
    
//    // original size
//    CGRect newRect = self.view.bounds;
//    newRect.origin.y = _textView.frame.origin.y;
//    newRect.size.height -= _textView.frame.origin.y;
//    // modify size
//    newRect.size.height -= kbRect.size.height;
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        _textView.frame = newRect;
//    }];
    
    // apparently insets is the way to go here
    // http://stackoverflow.com/questions/18431684/uitextview-cursor-below-frame-when-changing-frame
    UIEdgeInsets contentInset = self.textView.contentInset;
    contentInset.bottom = kbRect.size.height;
    
    UIEdgeInsets scrollInset = self.textView.scrollIndicatorInsets;
    scrollInset.bottom = kbRect.size.height;

    [UIView animateWithDuration:0.3 animations:^{
        self.textView.contentInset = contentInset;
        self.textView.scrollIndicatorInsets = scrollInset;
    }];
}

- (void)keyboardWillHide:(NSNotification *)n
{
//    NSLogFun();
    
    if(self.isPlayerEditor)
        return;

    CGRect kbRect = [[[n userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:self.view.window];
    
//    // original size
//    CGRect newRect = self.view.bounds;
//    newRect.origin.y = _textView.frame.origin.y;
//    newRect.size.height -= _textView.frame.origin.y;
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        _textView.frame = newRect;
//    }];
    
    // apparently insets is the way to go here
    // http://stackoverflow.com/questions/18431684/uitextview-cursor-below-frame-when-changing-frame
    UIEdgeInsets contentInset = self.textView.contentInset;
    contentInset.bottom = 0;
    
    UIEdgeInsets scrollInset = self.textView.scrollIndicatorInsets;
    scrollInset.bottom = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.textView.contentInset = contentInset;
        self.textView.scrollIndicatorInsets = scrollInset;
    }];
}


@end



@implementation NSString (CharacterEnumeration)

- (void)enumerateCharacters:(BOOL (^)(int pos, unichar c))block
               fromPosition:(NSInteger)index
                    reverse:(BOOL)reverse
{
    for(int i = index; reverse? (i >= 0) : (i < [self length]); reverse? i-- : i++)
    {
        if(!block(i, [self characterAtIndex:i])) break;
    }
}

- (void)enumerateCharacters:(BOOL (^)(int pos, unichar c))block
{
    [self enumerateCharacters:block fromPosition:0 reverse:NO];
}

@end



@implementation UITextView (Ranges)

- (UITextRange *)textRangeFromRange:(NSRange)range
{
    UITextPosition *docStart = self.beginningOfDocument;
    UITextPosition *start = [self positionFromPosition:docStart offset:range.location];
    UITextPosition *end = [self positionFromPosition:start offset:range.length];
    UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
    return textRange;
}

- (UITextPosition *)textPositionFromIndex:(NSInteger)index
{
    UITextPosition *docStart = self.beginningOfDocument;
    return [self positionFromPosition:docStart offset:index];
}

@end




