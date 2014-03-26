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
#import "mAMasterViewController.h"

@interface mAEditorViewController ()
{
    NSRange _errorRange;
}

@property (strong, nonatomic) mATextView * textView;

@property (strong, nonatomic) UIPopoverController * popover;
@property (strong, nonatomic) mATitleEditorController * titleEditor;

- (NSDictionary *)defaultTextAttributes;
- (NSDictionary *)errorTextAttributes;
- (void)configureView;

@end

@implementation mAEditorViewController

@synthesize textView = _textView;

@synthesize titleEditor = _titleEditor;

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


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if(_detailItem != newDetailItem)
    {
        if(_detailItem)
        {
            // save text
            _detailItem.text = self.textView.text;
        }
        
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.titleButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(editTitle:)];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        
        self.titleButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(editTitle:)];
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
    
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem)
    {
        self.titleButton.title = self.detailItem.title;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.detailItem.text
                                                                                 attributes:[self defaultTextAttributes]];
        [[mASyntaxHighlighting sharedHighlighter] colorString:text range:NSMakeRange(0, [text length]-1) colorer:nil];
        self.textView.attributedText = text;
    }
}


#pragma mark - IBActions

- (void)saveScript
{
    self.detailItem.text = self.textView.text;
}


- (IBAction)addShred
{
    if(self.detailItem == nil) return;
    
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
        //        [status_text setStringValue:@""];
        //
        //        if([self.windowController currentViewController] == self)
        //            [[text_view textView] animateAdd];
        //        [text_view setShowsErrorLine:NO];
        //        [self setErrorLine:-1];
        self.textView.errorLine = -1;
        self.textView.errorMessage = nil;
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
            //            [text_view setShowsErrorLine:YES];
            //            [text_view setErrorLine:error_line];
            //            [self setErrorLine:error_line];
            self.textView.errorLine = error_line;
            self.textView.errorMessage = [NSString stringWithUTF8String:result.c_str()];
        }
        
        //        if([self.windowController currentViewController] == self)
        //            [[text_view textView] animateError];
        //
        //        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
    else
    {
        //        if([self.windowController currentViewController] == self)
        //            [[text_view textView] animateError];
        //
        //        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
}


- (IBAction)replaceShred
{
    if(self.detailItem == nil) return;
    
    std::string code = [self.textView.text UTF8String];
    std::string name = [self.detailItem.title UTF8String];
    std::string filepath;
    if(self.detailItem.path && [self.detailItem.path length])
        filepath = [self.detailItem.path UTF8String];
    vector<string> args;
    t_CKUINT shred_id;
    std::string output;
    
    [mAChucKController chuckController].ma->replace_code(code, name, args, filepath,
                                                         self.detailItem.docid,
                                                         shred_id, output);
}


- (IBAction)removeShred
{
    if(self.detailItem == nil) return;
    
    t_CKUINT shred_id;
    std::string output;
    
    [mAChucKController chuckController].ma->remove_code(self.detailItem.docid, 
                                                        shred_id, output);
}


- (IBAction)editTitle:(id)sender
{
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
    
    self.detailItem.title = self.titleEditor.editedTitle;
    self.detailItem.text = self.textView.text;
    
    [self configureView];
    
    [self.masterViewController scriptDetailChanged];
}


- (void)titleEditorDidCancel:(mATitleEditorController *)titleEditor
{
    [self.popover dismissPopoverAnimated:YES];
}


#pragma mark - NSTextStorageDelegate

- (void)textStorage:(NSTextStorage *)textStorage
  didProcessEditing:(NSTextStorageEditActions)editedMask
              range:(NSRange)editedRange
     changeInLength:(NSInteger)delta
{
    NSUInteger start_index, line_end_index, contents_end_index;
    [[textStorage string] getLineStart:&start_index
                                   end:&line_end_index
                           contentsEnd:&contents_end_index
                              forRange:editedRange];
    
    [[mASyntaxHighlighting sharedHighlighter] colorString:textStorage
                                                    range:NSMakeRange( start_index, contents_end_index - start_index )
                                                  colorer:nil];
}

#pragma mark - mAKeyboardAccessoryDelegate

- (void)keyPressed:(NSString *)chars
{
    [self.textView insertText:chars];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //    NSLog(@"shouldChangeTextInRange: %i %i selectedRange: %i %i text: %@",
    //          range.location, range.length,
    //          [textView selectedRange].location, [textView selectedRange].length,
    //          text);
    if([text isEqualToString:@". "] && range.location != [textView selectedRange].location)
        return NO;
    return YES;
}


#pragma mark - mADetailClient

@end
