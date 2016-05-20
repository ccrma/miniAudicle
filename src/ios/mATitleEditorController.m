/*----------------------------------------------------------------------------
 miniAudicle iOS
 iOS GUI to chuck audio programming environment
 
 Copyright (c) 2005-2012 Spencer Salazar.  All rights reserved.
 http://chuck.cs.princeton.edu/
 http://soundlab.cs.princeton.edu/
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 U.S.A.
 -----------------------------------------------------------------------------*/

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

- (NSString *)editedTitle
{
    (void) self.view; // force view load
    
    // sanitize input
    NSString *title = self.textField.text;
    
    // remove leading/trailing space
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // force .ck extension
    NSString *extension = [title pathExtension];
    if(!extension || ![extension isEqualToString:@"ck"])
        title = [title stringByAppendingPathExtension:@"ck"];
    
    return title;
}

- (void)setEditedTitle:(NSString *)t
{
    (void) self.view; // force view load
    self.textField.text = t;
}

- (IBAction)confirm:(id)sender
{
    [self.delegate titleEditorDidConfirm:self];
//    [self.textField resignFirstResponder];
}


- (IBAction)cancel:(id)sender
{
    [self.delegate titleEditorDidCancel:self];
//    [self.textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.delegate titleEditorDidConfirm:self];
//    [self.textField resignFirstResponder];
    
    return YES;
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.contentSizeForViewInPopover = self.view.frame.size;
    self.preferredContentSize = self.view.frame.size;
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
