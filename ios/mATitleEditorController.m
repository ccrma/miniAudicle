//
//  mATitleEditViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 12/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "mATitleEditorController.h"


@interface mATitleEditorController ()

@property (strong, nonatomic) UITextField * textField;

@end



@implementation mATitleEditorController

@synthesize delegate = _delegate;
@synthesize textField = _textField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (NSString *)editedTitle
{
    (void) self.view; // force view load
    return self.textField.text;
}

- (void)setEditedTitle:(NSString *)t
{
    (void) self.view; // force view load
    self.textField.text = t;
}

- (IBAction)confirm:(id)sender
{
    [self.delegate titleEditorDidConfirm:self];
    [self.textField resignFirstResponder];
}


- (IBAction)cancel:(id)sender
{
    [self.delegate titleEditorDidCancel:self];
    [self.textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.delegate titleEditorDidConfirm:self];
    [self.textField resignFirstResponder];
    
    return YES;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = self.view.frame.size;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.textField resignFirstResponder];
}

@end
