//
//  mAKeyboardAccessoryViewViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/22/14.
//
//

#import "mAKeyboardAccessoryViewController.h"
#import "mAKeyboardButton.h"

@interface mAKeyboardAccessoryViewController ()

@end

@implementation mAKeyboardAccessoryViewController

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
    
    // this RGB gleaned with much effort from screenshots + eyeball color calibration
    // might be different for different hardware? 
    self.view.backgroundColor = [UIColor colorWithRed:207/255.0 green:210/255.0 blue:214/255.0 alpha:1];
    
    NSDictionary *coloredCodeAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Menlo-Bold" size:18],
                                             NSForegroundColorAttributeName: [UIColor blueColor] };
    
    _chuckButton.alternatives = @[@"<=", @"<<", @"=<", @"@=>"];
    _dacButton.alternatives = @[@"adc"];
    _dacButton.attributes = @[coloredCodeAttributes, coloredCodeAttributes];
    
    _doublequoteButton.keyInsertText = @"\"\"";
    _doublequoteButton.alternatives = @[@"\""];
    
    _braceButton.keyInsertText = @"{}";
    _braceButton.alternatives = @[@"{", @"}"];
    
    _bracketButton.keyInsertText = @"[]";
    _bracketButton.alternatives = @[@"[", @"]"];
    
    _parenButton.keyInsertText = @"()";
    _parenButton.alternatives = @[@"(", @")"];
    
    _doublequoteButton.cursorOffset = _braceButton.cursorOffset = _bracketButton.cursorOffset = _parenButton.cursorOffset = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)keyPressed:(id)sender
{
    [self.delegate keyPressed:[sender pressedKey] selectionOffset:[sender cursorOffset]];
}

@end
