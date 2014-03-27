//
//  mAScriptPlayer.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import "mAScriptPlayer.h"
#import "mADetailItem.h"
#import "mAChucKController.h"
#import "miniAudicle.h"

@interface mAScriptPlayer ()

@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation mAScriptPlayer

@synthesize titleLabel = _titleLabel;

- (void)setDetailItem:(mADetailItem *)detailItem
{
    _detailItem = detailItem;
    self.titleLabel.text = detailItem.title;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = self.detailItem.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addShred:(id)sender
{
    if(self.detailItem == nil) return;
    
    std::string code = [self.detailItem.text UTF8String];
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
//        self.textView.errorLine = -1;
//        self.textView.errorMessage = nil;
    }
    else if( otf_result == OTF_VM_TIMEOUT )
    {
        //        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
        //        [mac setLockdown:YES];
    }
    else if( otf_result == OTF_COMPILE_ERROR )
    {
//        int error_line;
//        std::string result;
//        if( [mAChucKController chuckController].ma->get_last_result( self.detailItem.docid, NULL, &result, &error_line ) )
//        {
//            self.textView.errorLine = error_line;
//            self.textView.errorMessage = [NSString stringWithUTF8String:result.c_str()];
//        }
        
        //        if([self.windowController currentViewController] == self)
        //            [[text_view textView] animateError];
    }
    else
    {
        //        if([self.windowController currentViewController] == self)
        //            [[text_view textView] animateError];
        //
        //        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
}


- (IBAction)replaceShred:(id)sender
{
    if(self.detailItem == nil) return;
    
    std::string code = [self.detailItem.text UTF8String];
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
//        self.textView.errorLine = -1;
//        self.textView.errorMessage = nil;
    }
    else if( otf_result == OTF_VM_TIMEOUT )
    {
        //        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
        //        [mac setLockdown:YES];
    }
    else if( otf_result == OTF_COMPILE_ERROR )
    {
//        int error_line;
//        std::string result;
//        if( [mAChucKController chuckController].ma->get_last_result( self.detailItem.docid, NULL, &result, &error_line ) )
//        {
//            self.textView.errorLine = error_line;
//            self.textView.errorMessage = [NSString stringWithUTF8String:result.c_str()];
//        }
        
        //        if([self.windowController currentViewController] == self)
        //            [[text_view textView] animateError];
    }
    else
    {
        //        if([self.windowController currentViewController] == self)
        //            [[text_view textView] animateError];
        //
        //        [status_text setStringValue:[NSString stringWithUTF8String:result.c_str()]];
    }
}


- (IBAction)removeShred:(id)sender
{
    if(self.detailItem == nil) return;
    
    t_CKUINT shred_id;
    std::string output;
    
    [mAChucKController chuckController].ma->remove_code(self.detailItem.docid, 
                                                        shred_id, output);
}



@end
