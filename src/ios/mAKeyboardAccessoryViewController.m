//
//  mAKeyboardAccessoryViewViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/22/14.
//
//

#import "mAKeyboardAccessoryViewController.h"
#import "mAKeyboardButton.h"

#define CKKB_NAME @"name"
#define CKKB_ALTERNATES @"alternates"
#define CKKB_ATTRIBUTES @"attributes"
#define CKKB_OFFSET @"offset"
#define CKKB_TEXT @"text"
#define CKKB_EXTRA_SPACE @"extra_space"

static NSArray *g_chuckKeyboard = nil;

@interface mAKeyboardAccessoryViewController ()

@end

@implementation mAKeyboardAccessoryViewController

+ (void)initialize
{
    if(g_chuckKeyboard == nil)
    {
        NSDictionary *coloredCodeAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Menlo-Bold" size:18],
                                                 NSForegroundColorAttributeName: [UIColor blueColor] };
        NSDictionary *singleCodeAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:20],
                                                NSForegroundColorAttributeName: [UIColor blackColor] };
        NSDictionary *smallCodeAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12],
                                               NSForegroundColorAttributeName: [UIColor blackColor] };
        
        // keyboard info
        g_chuckKeyboard = @[
                            /* column */
                            @[ @{ CKKB_NAME: @";", CKKB_ATTRIBUTES: singleCodeAttributes } ],
                            /* column */
                            @[ @{ CKKB_NAME: @"{}", CKKB_OFFSET: @-1, CKKB_TEXT: @"{}",
                                  CKKB_ATTRIBUTES: singleCodeAttributes,
                                  CKKB_ALTERNATES: @[ @{ CKKB_NAME: @"{", }, @{ CKKB_NAME: @"}", }, ]
                                  } ],
                            /* column */
                            @[ @{ CKKB_NAME: @"[]", CKKB_OFFSET: @-1, CKKB_TEXT: @"[]",
                                  CKKB_ATTRIBUTES: singleCodeAttributes,
                                  CKKB_ALTERNATES: @[ @{ CKKB_NAME: @"[", }, @{ CKKB_NAME: @"]", }, ]
                                  } ],
                            /* column */
                            @[ @{ CKKB_NAME: @"()", CKKB_OFFSET: @-1, CKKB_TEXT: @"()",
                                  CKKB_ATTRIBUTES: singleCodeAttributes,
                                  CKKB_ALTERNATES: @[ @{ CKKB_NAME: @"(", }, @{ CKKB_NAME: @")", }, ]
                                  } ],
                            /* column */
                            @[ @{ CKKB_NAME: @"==",
                                  CKKB_ALTERNATES: @[
                                          @{ CKKB_NAME: @"!=", },
                                          @{ CKKB_NAME: @"<=", },
                                          @{ CKKB_NAME: @">=", },
                                          ], },
                               @{ CKKB_NAME: @"\"", CKKB_OFFSET: @-1, CKKB_TEXT: @"\"\"", }, ],
                            /* column */
                            @[ @{ CKKB_NAME: @"*", },
                               @{ CKKB_NAME: @"/", }, ],
                            /* column */
                            @[ @{ CKKB_NAME: @"+", },
                               @{ CKKB_NAME: @"-", }, ],
                            /* column */
                            @[ @{ CKKB_NAME: @"::", },
                               @{ CKKB_NAME: @"<<<>>>", CKKB_ATTRIBUTES: smallCodeAttributes,
                                  CKKB_OFFSET: @-1, CKKB_TEXT: @"<<<>>>", }, ],
                            /* column */
                            @[ @{ CKKB_NAME: @"dac", CKKB_ATTRIBUTES: coloredCodeAttributes,
                                  CKKB_ALTERNATES: @[ @{ CKKB_NAME: @"adc", CKKB_ATTRIBUTES: coloredCodeAttributes, } ]
                                  } ],
                            /* column */
                            @[ @{ CKKB_NAME: @"now", CKKB_ATTRIBUTES: coloredCodeAttributes, } ],
                            /* column */
                            @[ @{ CKKB_NAME: @"=>", CKKB_EXTRA_SPACE: @YES,
                                  CKKB_ATTRIBUTES: @{ NSFontAttributeName: [UIFont fontWithName:@"Menlo-Bold" size:28],
                                                      NSForegroundColorAttributeName: [UIColor blackColor] },
                                  CKKB_ALTERNATES: @[ @{ CKKB_NAME: @"<=", },
                                                      @{ CKKB_NAME: @"<<", },
                                                      @{ CKKB_NAME: @"=<", },
                                                      @{ CKKB_NAME: @"@=>", }, ]
                                  } ],
                            ];
    }
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
    
    // this RGB gleaned with much effort from screenshots + eyeball color calibration
    // might be different for different hardware? 
    self.view.backgroundColor = [UIColor colorWithRed:207/255.0 green:210/255.0 blue:214/255.0 alpha:1];
    
    NSDictionary *codeAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:16],
                                      NSForegroundColorAttributeName: [UIColor blackColor] };

    // clear all subviews
    for(UIView *view in [self.view subviews])
        [view removeFromSuperview];
    
    // layout keyboard

    float width = self.view.bounds.size.width;
    float height = self.view.bounds.size.height;
    float inner_horz_margin = 12;
    float outer_horz_margin = 7;
    float inner_vert_margin = 8;
    float force_extra_button_width = 10;
    float total_button_width = width - (outer_horz_margin*2+inner_horz_margin*(g_chuckKeyboard.count-1) + force_extra_button_width);
    float single_button_width = floor(total_button_width/g_chuckKeyboard.count);
    float extra_button_width = total_button_width + force_extra_button_width - single_button_width*g_chuckKeyboard.count;
    float single_button_height = single_button_width;
    float half_button_height = (single_button_height-inner_vert_margin)/2;
    float outer_vert_margin = (height-single_button_height)/2;
    
    float x = outer_horz_margin;
    
    for(NSArray *column in g_chuckKeyboard)
    {
        int cnt = [column count];
        assert(cnt == 1 || cnt == 2);
        
        float y = outer_vert_margin;
        float button_width = single_button_width;
        float button_height = single_button_height;
        if(cnt == 2)
            button_height = half_button_height;
        
        for(NSDictionary *key in column) // should be 1 or 2 keys
        {
            if([key objectForKey:CKKB_EXTRA_SPACE] && [key[CKKB_EXTRA_SPACE] boolValue])
                button_width += extra_button_width;
            mAKeyboardButton *button = [[mAKeyboardButton alloc] initWithFrame:CGRectMake(x, y, button_width, button_height)];
            if([key objectForKey:CKKB_ATTRIBUTES])
                [button setAttributedTitle:[[NSAttributedString alloc] initWithString:key[CKKB_NAME]
                                                                           attributes:key[CKKB_ATTRIBUTES]]
                                  forState:UIControlStateNormal];
            else
                [button setAttributedTitle:[[NSAttributedString alloc] initWithString:key[CKKB_NAME]
                                                                           attributes:codeAttributes]
                                  forState:UIControlStateNormal];
            if([key objectForKey:CKKB_TEXT])
                button.keyInsertText = key[CKKB_TEXT];
            if([key objectForKey:CKKB_OFFSET])
                button.cursorOffset = [key[CKKB_OFFSET] intValue];
            
            if([key objectForKey:CKKB_ALTERNATES])
            {
                NSMutableArray *alts = [NSMutableArray array];
                NSMutableArray *altAttrs = [NSMutableArray array];
                for(NSDictionary *alt in key[CKKB_ALTERNATES])
                {
                    [alts addObject:alt[CKKB_NAME]];
                    if([alt objectForKey:CKKB_ATTRIBUTES])
                        [altAttrs addObject:alt[CKKB_ATTRIBUTES]];
                    else
                        [altAttrs addObject:codeAttributes];
                }
                
                button.alternatives = alts;
                button.attributes = altAttrs;
            }
            
            [button addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.view addSubview:button];
            
            y += button_height+inner_vert_margin;
        }
        
        x += button_width+inner_horz_margin;
    }
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
