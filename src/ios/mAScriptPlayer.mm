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
#import "mAShredButton.h"
#import <map>
#import <list>

using namespace std;


@interface NSArray (indexOfObjectWithValue)

- (NSUInteger)indexOfObjectWithUnsignedLongValue:(unsigned long)val;

@end



@interface mAScriptPlayer ()
{
    map<t_CKUINT, mAShredButton *> _shredIdToButton;
    list<t_CKUINT> _shredOrder;
}

@property (strong, nonatomic) UILabel *titleLabel;

- (void)shredButton:(id)sender;
- (void)addShredButton:(t_CKUINT)shredId;
- (void)removeShredButton:(t_CKUINT)shredId;
- (void)relayoutShredButtons;

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
        [self addShredButton:shred_id];
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
    
    [self removeShredButton:shred_id];
}


- (void)updateWithStatus:(Chuck_VM_Status *)status
{
    
}

- (void)addShredButton:(t_CKUINT)shredId
{
    if(_shredIdToButton.count(shredId) == 0)
    {
        mAShredButton *shredView = [mAShredButton buttonWithType:UIButtonTypeCustom];
        float width = 25;
        int idx = _shredOrder.size();
        int xIdx = idx/2;
        int yIdx = idx%2;
        shredView.frame = CGRectMake(0, 0, width, width);
        shredView.center = CGPointMake(self.view.bounds.origin.x + self.view.bounds.size.width*3.0f/4.0f + xIdx*(width+4),
                                       CGRectGetMidY(self.view.bounds) - (1-yIdx)*(width+4));
        shredView.tag = shredId;
        
        
        [self.view addSubview:shredView];
        _shredIdToButton[shredId] = shredView;
        _shredOrder.push_back(shredId);
        
        [shredView addTarget:self
                      action:@selector(shredButton:)
            forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)removeShredButton:(unsigned long)shredId
{
    if(_shredIdToButton.count(shredId) > 0)
    {
        [_shredIdToButton[shredId] removeFromSuperview];
        _shredIdToButton.erase(shredId);
        BOOL relayout = NO;
        if(_shredOrder.back() != shredId)
            relayout = YES;
        _shredOrder.remove(shredId);
        if(relayout)
            [self relayoutShredButtons];
    }
}

- (void)relayoutShredButtons
{
    int idx = 0;
    for(list<t_CKUINT>::iterator i = _shredOrder.begin(); i != _shredOrder.end(); i++)
    {
        mAShredButton *shredView = _shredIdToButton[*i];
        float width = 25;
        int xIdx = idx/2;
        int yIdx = idx%2;
        shredView.center = CGPointMake(self.view.bounds.origin.x + self.view.bounds.size.width*3.0f/4.0f + xIdx*(width+4),
                                       CGRectGetMidY(self.view.bounds) - (1-yIdx)*(width+4));
        idx++;
    }
}

- (void)shredButton:(id)sender
{
    t_CKUINT shredId = [sender tag];
    std::string output;
    [mAChucKController chuckController].ma->remove_shred(self.detailItem.docid, shredId, output);
    [self removeShredButton:shredId];
}

@end


@implementation NSArray (indexOfObjectWithValue)

- (NSUInteger)indexOfObjectWithUnsignedLongValue:(unsigned long)val
{
    return [self indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop){
        return [obj unsignedLongValue] == val;
    }];
}

@end



