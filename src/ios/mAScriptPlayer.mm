//
//  mAScriptPlayer.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import "mAScriptPlayer.h"
#import "mAScriptPlayerTab.h"
#import "mADetailItem.h"
#import "mAChucKController.h"
#import "miniAudicle.h"
#import "mAShredButton.h"
#import "mAPlayerViewController.h"
#import "mAOTFButton.h"

#import <map>
#import <list>

using namespace std;

static const t_CKFLOAT MAX_SHRED_TIMEOUT = 0.1;


@interface NSArray (indexOfObjectWithValue)

- (NSUInteger)indexOfObjectWithUnsignedLongValue:(unsigned long)val;

@end


struct Shred
{
    Shred() : button(nil), timeout(0), timeoutMax(MAX_SHRED_TIMEOUT) { }
    mAShredButton *button;
    t_CKFLOAT timeout;
    t_CKFLOAT timeoutMax;
    
    void reset() { timeout = 0; timeoutMax = MAX_SHRED_TIMEOUT; }
};


struct LoopShred
{
    t_CKINT loopCount;
    string code;
    string name;
    string filepath;
    vector<string> args;
};


@interface mAScriptPlayer ()
{
//    map<t_CKUINT, mAShredButton *> _shredIdToButton;
//    map<t_CKUINT, t_CKFLOAT> _shredTimeouts;
    map<t_CKUINT, Shred> _shreds; // shred id -> info
    map<t_CKUINT, LoopShred> _loopShreds; // shred ids -> loop count
    t_CKFLOAT _lastTime;
    list<t_CKUINT> _shredOrder;
}

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) mAScriptPlayerTab *playerTabView;


- (void)shredButton:(id)sender;
- (void)addShredButton:(t_CKUINT)shredId;
- (void)removeShredButton:(t_CKUINT)shredId;
- (void)relayoutShredButtons;

@end

@implementation mAScriptPlayer

- (void)setPlayerViewController:(mAPlayerViewController *)playerViewController
{
    _playerViewController = playerViewController;
    self.playerTabView.playerViewController = playerViewController;
}

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
    _lastTime = CACurrentMediaTime();
    self.playerTabView.playerViewController = self.playerViewController;
    
    _addButton.image = [UIImage imageNamed:@"add-noalpha.png"];
    _addButton.insets = UIEdgeInsetsMake(2, 0, -2, 0);
    _addButton.alternatives = @[_loopButton, _loopNButton, _sequenceButton];
    
    _loopButton.image = [UIImage imageNamed:@"loop.png"];
    _loopNButton.image = [UIImage imageNamed:@"loop.png"];
    _loopNButton.text = @"#";
    _sequenceButton.image = [UIImage imageNamed:@"sequence.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

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


- (IBAction)loopShred:(id)sender
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
        
        _loopShreds[shred_id] = LoopShred();
        _loopShreds[shred_id].loopCount = -1;
        _loopShreds[shred_id].code = code;
        _loopShreds[shred_id].name = name;
        _loopShreds[shred_id].filepath = filepath;
        _loopShreds[shred_id].args = args;
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


- (IBAction)loopNShred:(id)sender
{
    NSLog(@"loopN");
}


- (IBAction)sequenceShred:(id)sender
{
    NSLog(@"sequence");
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

- (IBAction)edit:(id)sender
{
    [self.playerViewController showEditorForScriptPlayer:self];
}


- (void)updateWithStatus:(Chuck_VM_Status *)status
{
    t_CKFLOAT currentTime = CACurrentMediaTime();
    t_CKFLOAT deltaTime = (currentTime - _lastTime);
    
    list<t_CKUINT> removeList;
    for(map<t_CKUINT, Shred>::iterator myShred = _shreds.begin();
        myShred != _shreds.end(); myShred++)
    {
        int shredId = myShred->first;
        
        // todo: optimize this somehow? 
        bool foundIt = false;
        for(vector<Chuck_VM_Shred_Status *>::iterator shred = status->list.begin();
            shred != status->list.end(); shred++)
        {
            if((*shred)->xid == shredId)
            {
                foundIt = true;
                break;
            }
        }
        
        if(!foundIt)
        {
            _shreds[shredId].timeout += (deltaTime);
        }
        else
        {
            _shreds[shredId].timeout = 0;
            _shreds[shredId].timeoutMax = 0;
        }
        
        if(_shreds[shredId].timeout > _shreds[shredId].timeoutMax)
            removeList.push_back(shredId);
    }
    
    for(list<t_CKUINT>::iterator rm = removeList.begin(); rm != removeList.end(); rm++)
    {
        t_CKUINT shred_id = *rm;
        if(_loopShreds.count(shred_id) && _loopShreds[shred_id].loopCount != 0)
        {
            /* continue looping */
            
            if(_loopShreds[shred_id].loopCount > 0)
                _loopShreds[shred_id].loopCount--;
            
            t_CKUINT new_shred_id;
            std::string output;
            
            t_OTF_RESULT otf_result = [mAChucKController chuckController].ma->run_code(_loopShreds[shred_id].code,
                                                                                       _loopShreds[shred_id].name,
                                                                                       _loopShreds[shred_id].args,
                                                                                       _loopShreds[shred_id].filepath,
                                                                                       self.detailItem.docid,
                                                                                       new_shred_id, output);
            
            if( otf_result == OTF_SUCCESS )
            {
                if(new_shred_id != shred_id)
                {
                    // swap to new shred id (if necessary)
                    _loopShreds[new_shred_id] = _loopShreds[shred_id];
                    _loopShreds.erase(shred_id);
                    _shreds[new_shred_id] = _shreds[shred_id];
                    _shreds.erase(shred_id);
                }
                
                _shreds[new_shred_id].reset();
            }
            else if( otf_result == OTF_VM_TIMEOUT )
            {
            }
            else if( otf_result == OTF_COMPILE_ERROR )
            {
                _loopShreds.erase(shred_id);
            }
            else
            {
                _loopShreds.erase(shred_id);
            }
        }
        else
        {
            /* remove shred from our list */
            [self removeShredButton:shred_id];
        }
    }
    
    _lastTime = currentTime;
}

- (void)addShredButton:(t_CKUINT)shredId
{
    if(_shreds.count(shredId) == 0)
    {
        mAShredButton *shredView = [mAShredButton buttonWithType:UIButtonTypeCustom];
        float width = 25;
        int idx = _shredOrder.size();
        int xIdx = idx/2;
        int yIdx = idx%2;
        shredView.frame = CGRectMake(0, 0, width, width);
        shredView.center = CGPointMake(self.view.bounds.origin.x + self.view.bounds.size.width*5.0f/6.0f + xIdx*(width+4),
                                       CGRectGetMidY(self.view.bounds) - (1-yIdx)*(width+4));
        shredView.tag = shredId;
        
        
        [self.view addSubview:shredView];
        
        _shreds[shredId] = Shred();
        _shreds[shredId].button = shredView;
        _shredOrder.push_back(shredId);
        
        [shredView addTarget:self
                      action:@selector(shredButton:)
            forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)removeShredButton:(unsigned long)shredId
{
    if(_shreds.count(shredId) > 0)
    {
        [_shreds[shredId].button removeFromSuperview];
        _shreds.erase(shredId);
        if(_loopShreds.count(shredId)) _loopShreds.erase(shredId);
        
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
        mAShredButton *shredView = _shreds[*i].button;
        float width = 25;
        int xIdx = idx/2;
        int yIdx = idx%2;
        shredView.center = CGPointMake(self.view.bounds.origin.x + self.view.bounds.size.width*5.0f/6.0f + xIdx*(width+4),
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

- (UIView *)viewForEditorPopover
{
    return self.view;
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



