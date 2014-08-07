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
#import "mAEditorViewController.h"
#import "mALoopCountPicker.h"
#import "mARoundedRectButton.h"
#import "mANetworkManager.h"
#import "mANetworkAction.h"

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

@property (strong, nonatomic) mALoopCountPicker *loopCountPicker;
@property (strong, nonatomic) UIPopoverController *loopCountPickerPopover;


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
    if(self.detailItem.remote)
        _usernameLabel.text = self.detailItem.remoteUsername;
    else
        _usernameLabel.text = @"";
    if(_detailItem.remote) [self makeRemote];
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
    
    // reset detail item to ensure setting of various widgets
    self.detailItem = self.detailItem;
    
    _lastTime = CACurrentMediaTime();
    self.playerTabView.playerViewController = self.playerViewController;
    
    _addButton.image = [UIImage imageNamed:@"add-noalpha.png"];
    _addButton.insets = UIEdgeInsetsMake(2, 0, -2, 0);
    
    _loopButton.image = [UIImage imageNamed:@"loop.png"];
    _loopNButton.image = [UIImage imageNamed:@"loop.png"];
    _loopNButton.text = @"#";
    _sequenceButton.image = [UIImage imageNamed:@"sequence.png"];
    
    _addButton.alternatives = @[_loopButton, _loopNButton, _sequenceButton];
    
    if(_detailItem.remote) [self makeRemote];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)makeRemote
{
//    self.playerTabView.tintColor = [UIColor colorWithRed:0 green:0.45 blue:0.9 alpha:1.0];
    self.playerTabView.tintColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    [_addButton removeFromSuperview];
    [_replaceButton removeFromSuperview];
    [_removeButton removeFromSuperview];
}


#pragma mark - IBActions

- (IBAction)addShred:(id)sender
{
    if(self.detailItem == nil) return;
    
    // save script if necessary
    if(self.detailItem == self.playerViewController.editor.detailItem)
        [self.playerViewController.editor saveScript];
    
    [_addButton collapse];
    
    if(!self.detailItem.remote && [[mANetworkManager instance] isConnected])
    {
        mANAAddShred *addShred = [mANAAddShred new];
        addShred.code_id = self.codeID;
        [[mANetworkManager instance] submitAction:addShred
                                     errorHandler:^(NSError *error) {
                                         NSLog(@"error submitting addShred action: %@", error);
                                     }];
    }
    
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


- (void)loopWithCount:(int)count
{
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
        _loopShreds[shred_id].loopCount = count - 1;
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


- (IBAction)loopShred:(id)sender
{
    if(self.detailItem == nil) return;
    
    // save script if necessary
    if(self.detailItem == self.playerViewController.editor.detailItem)
        [self.playerViewController.editor saveScript];
    
    [_addButton collapseToAlternative:_loopButton];
    
    [self loopWithCount:-1];
}


- (IBAction)loopNShred:(id)sender
{
    if(self.detailItem == nil) return;
    
    // save script if necessary
    if(self.detailItem == self.playerViewController.editor.detailItem)
        [self.playerViewController.editor saveScript];
    
    if(self.loopCountPicker == nil)
        self.loopCountPicker = [[mALoopCountPicker alloc] initWithNibName:@"mALoopCountPicker" bundle:nil];
    if(self.loopCountPickerPopover == nil)
        self.loopCountPickerPopover = [[UIPopoverController alloc] initWithContentViewController:self.loopCountPicker];
    
    self.loopCountPickerPopover.delegate = self.loopCountPicker;
    
    [self.loopCountPickerPopover presentPopoverFromRect:[sender frame]
                                                 inView:self.view
                               permittedArrowDirections:UIPopoverArrowDirectionAny
                                               animated:YES];
    
    __weak typeof(_loopNButton) weakLoopNButton = _loopNButton;
    __weak typeof(_addButton) weakAddButton = _addButton;
    __weak typeof(self) weakSelf = self;
    
    self.loopCountPicker.pickedLoopCount = ^(NSInteger count){
        [weakSelf loopWithCount:count];
        weakLoopNButton.text = [NSString stringWithFormat:@"%i", (int)count];
        
        [weakSelf.loopCountPickerPopover dismissPopoverAnimated:YES];
//        weakSelf.loopCountPickerPopover = nil;
//        weakSelf.loopCountPicker = nil;
        
        [weakAddButton collapseToAlternative:weakLoopNButton];
    };
    
    self.loopCountPicker.cancelled = ^(){
        [weakSelf.loopCountPickerPopover dismissPopoverAnimated:YES];
//        weakSelf.loopCountPickerPopover = nil;
//        weakSelf.loopCountPicker = nil;

        [weakAddButton collapse];
    };
}


- (IBAction)sequenceShred:(id)sender
{
    NSLog(@"sequence");
    
    [_addButton collapseToAlternative:_sequenceButton];
}


- (IBAction)replaceShred:(id)sender
{
    if(self.detailItem == nil) return;
    
    // save script if necessary
    if(self.detailItem == self.playerViewController.editor.detailItem)
       [self.playerViewController.editor saveScript];
    
    if(!self.detailItem.remote && [[mANetworkManager instance] isConnected])
    {
        mANAReplaceShred *replaceShred = [mANAReplaceShred new];
        replaceShred.code_id = self.codeID;
        [[mANetworkManager instance] submitAction:replaceShred
                                     errorHandler:^(NSError *error) {
                                         NSLog(@"error submitting replaceShred action: %@", error);
                                     }];
    }

    
    std::string code = [self.detailItem.text UTF8String];
    std::string name = [self.detailItem.title UTF8String];
    std::string filepath;
    if(self.detailItem.path && [self.detailItem.path length])
        filepath = [self.detailItem.path UTF8String];

    // if most recent shred is looping, just replacing loop code
    if(_shredOrder.size())
    {
        t_CKUINT shred_id = _shredOrder.back();
        if(_loopShreds.count(shred_id))
        {
            _loopShreds[shred_id].code = code;
            _loopShreds[shred_id].name = name;
            _loopShreds[shred_id].filepath = filepath;
            
            // assumption: the new shred in a replace operation has same id
            return;
        }
    }
    
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
    
    if(!self.detailItem.remote && [[mANetworkManager instance] isConnected])
    {
        mANARemoveShred *removeShred = [mANARemoveShred new];
        removeShred.code_id = self.codeID;
        [[mANetworkManager instance] submitAction:removeShred
                                     errorHandler:^(NSError *error) {
                                         NSLog(@"error submitting removeShred action: %@", error);
                                     }];
    }
    
    t_CKUINT shred_id;
    std::string output;
    
    t_OTF_RESULT otf_result = [mAChucKController chuckController].ma->remove_code(self.detailItem.docid,
                                                                                  shred_id, output);
    
    if(otf_result == OTF_SUCCESS)
    {
        if(_loopShreds.count(shred_id))
            _loopShreds.erase(shred_id);
        [self removeShredButton:shred_id];
    }
}

- (IBAction)edit:(id)sender
{
    [self.playerViewController showEditorForScriptPlayer:self];
}

- (void)removePlayer:(id)sender
{
    
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
            {
                _loopShreds[shred_id].loopCount--;
                _loopNButton.text = [NSString stringWithFormat:@"%i", (int) _loopShreds[shred_id].loopCount+1];
            }
            
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
        if(_loopShreds.count(shredId) > 0) _loopShreds.erase(shredId);
        
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
    
    if(_loopShreds.count(shredId))
        _loopShreds.erase(shredId);
    
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



