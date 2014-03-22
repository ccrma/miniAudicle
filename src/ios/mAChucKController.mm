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

#import "mAChucKController.h"
#import "miniAudicle.h"


static mAChucKController * g_chuckController = nil;


@implementation mAChucKController

@synthesize ma;

+ (void)initialize
{
    if(g_chuckController == nil)
        g_chuckController = [mAChucKController new];
}

+ (mAChucKController *)chuckController
{
    return g_chuckController;
}

- (id)init
{
    if(self = [super init])
    {
        ma = new miniAudicle;
        
#ifdef TARGET_IPHONE_SIMULATOR
        ma->set_sample_rate(44100);
        ma->set_buffer_size(512);
#else 
        ma->set_sample_rate(44100);
        ma->set_buffer_size(256);
#endif // TARGET_IPHONE_SIMULATOR
        
        ma->set_num_inputs(2);
        ma->set_num_outputs(2);
        ma->set_enable_audio(TRUE);
        ma->set_log_level(2);
    }
    
    return self;
}

@end
