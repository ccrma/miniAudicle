#import "mABrowserController.h"
#import "miniAudicleController.h"

#import "chuck_globals.h"
#import "chuck_type.h"
#import "chuck_compile.h"
#import "rtmidi.h"
#import "RtAudio/RtAudio.h"
#import "hidio_sdl.h"

struct Chuck_Type;

enum
{
    types_compare_classes_context
};

// 1.2.2: changed return type from 'int' to 'NSInteger' (64-bit fix)
static NSInteger types_compare( id a, id b, void * context )
{
    return [[a objectForKey:@"name"] compare:[b objectForKey:@"name"]];
}

static const char * exclude_types[] =
{ 
    "int",
    "float",
    "dur",
    "time",
    "void",
    "ADC",
    "DAC",
    "Class"
};

@implementation mABrowserController

- (id)init
{
    if( self = [super init] )
    {
        root = [NSMutableArray new];
        audio = midi = hid = nil;
        vm_on = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [audio release];
    [midi release];
    [hid release];
    
    [super dealloc];
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector( virtualMachineDidTurnOn: )
                                                 name:mAVirtualMachineDidTurnOnNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector( virtualMachineDidTurnOff: )
                                                 name:mAVirtualMachineDidTurnOffNotification
                                               object:nil];
    
    [window setExcludedFromWindowsMenu:YES];
    [window center];
    
    [self changeSource:self];
}

- (void)probeTypes
{
    [root removeAllObjects];
    
    if( !vm_on )
        return;
    
    vector< Chuck_Type * > types;
    g_compiler->env->global()->get_types( types );
    
    NSMutableArray * ugens = [[NSMutableArray new] autorelease],
        * classes = [[NSMutableArray new] autorelease];
    
    [root addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
        @"UGens", @"name",
        ugens, @"data",
        [NSNumber numberWithBool:NO], @"leaf",
        nil]];
    
    [root addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
        @"Classes", @"name",
        classes, @"data",
        [NSNumber numberWithBool:NO], @"leaf",
        nil]];
    
    vector< Chuck_Type * >::size_type i = 0, len = types.size();
    for( ; i < len; i++ )
    {
        Chuck_Type * type = types[i];
        string name = type->name;
        if( name[0] == '@' )
            continue;
        
        int skip = 0;
        for( size_t j = 0; j < ( sizeof( exclude_types ) / sizeof( const char * ) ); j++ )
        {
            if( name == exclude_types[j] )
            {
                skip = 1;
                break;
            }
        }
        
        if( skip )
            continue;
        
        NSDictionary * class_dict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithUTF8String:name.c_str()], @"name",
            [NSNumber numberWithBool:YES], @"leaf",
            nil];
        
        if( type->ugen_info )
            [ugens addObject:class_dict];
        else
            [classes addObject:class_dict];
    }
    
    [ugens sortUsingFunction:types_compare context:( void * )types_compare_classes_context];
    [classes sortUsingFunction:types_compare context:( void * )types_compare_classes_context];
}

- (void)probeAudio
{
    //[root removeAllObjects];
    
    if( audio == nil )
    {
        audio = [NSMutableArray new];
        
        RtAudio * rta = NULL;
        RtAudio::DeviceInfo info;
        
        // allocate RtAudio
        try { rta = new RtAudio( ); }
        catch( RtError err )
        {
            // problem finding audio devices, most likely
            return;
        }
        
        // get count    
        int devices = rta->getDeviceCount();
        
        // loop
        for( int i = 1; i <= devices; i++ )
        {
            try { info = rta->getDeviceInfo( i ); }
            catch( RtError & error )
        { 
                break;
        }
            
            NSMutableArray * device = [[NSMutableArray new] autorelease];
            
            [device addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                @"Output Channels", @"name",
                [NSString stringWithFormat:@"%i", info.outputChannels], @"description",
                [NSNumber numberWithBool:YES], @"leaf",
                nil]];
            
            [device addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                @"Input Channels", @"name",
                [NSString stringWithFormat:@"%i", info.inputChannels], @"description",
                [NSNumber numberWithBool:YES], @"leaf",
                nil]];
            
            [device addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                @"Duplex Channels", @"name",
                [NSString stringWithFormat:@"%i", info.duplexChannels], @"description",
                [NSNumber numberWithBool:YES], @"leaf",
                nil]];
            
            NSMutableString * sample_rates = [[NSMutableString new] autorelease];
            
            for( int j = 0; j < info.sampleRates.size(); j++ )
            {
                if( j != 0 )
                    [sample_rates appendString:@", "];
                [sample_rates appendString:[NSString stringWithFormat:@"%i", info.sampleRates[j]]];
            }
            
            [device addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                @"Sample Rates", @"name",
                sample_rates, @"description",
                [NSNumber numberWithBool:YES], @"leaf",
                nil]];
            
            NSMutableString * native_formats = [[NSMutableString new] autorelease];
            
            if( info.nativeFormats & RTAUDIO_SINT8 )
            {
                if( [native_formats length] > 0 )
                    [native_formats appendString:@", "];
                [native_formats appendString:@"8-bit int"];
            }
            
            if( info.nativeFormats & RTAUDIO_SINT16 )
            {
                if( [native_formats length] > 0 )
                    [native_formats appendString:@", "];
                [native_formats appendString:@"16-bit int"];
            }
            
            if( info.nativeFormats & RTAUDIO_SINT24 )
            {
                if( [native_formats length] > 0 )
                    [native_formats appendString:@", "];
                [native_formats appendString:@"24-bit int"];
            }
            
            if( info.nativeFormats & RTAUDIO_SINT32 )
            {
                if( [native_formats length] > 0 )
                    [native_formats appendString:@", "];
                [native_formats appendString:@"32-bit int"];
            }
            
            if( info.nativeFormats & RTAUDIO_FLOAT32 )
            {
                if( [native_formats length] > 0 )
                    [native_formats appendString:@", "];
                [native_formats appendString:@"32-bit float"];
            }
            
            if( info.nativeFormats & RTAUDIO_FLOAT64 )
            {
                if( [native_formats length] > 0 )
                    [native_formats appendString:@", "];
                [native_formats appendString:@"64-bit float"];
            }
            
            [device addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                @"Native Formats", @"name",
                native_formats, @"description",
                [NSNumber numberWithBool:YES], @"leaf",
                nil]];
            
            [device addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               @"Default Output", @"name",
                               ( info.isDefaultOutput ? @"Yes" : @"No" ), @"description",
                               [NSNumber numberWithBool:YES], @"leaf",
                               nil]];
            
            [device addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               @"Default Input", @"name",
                               ( info.isDefaultInput ? @"Yes" : @"No" ), @"description",
                               [NSNumber numberWithBool:YES], @"leaf",
                               nil]];
            
            [audio addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%i", i], @"name",
                [NSString stringWithUTF8String:info.name.c_str()], @"description",
                device, @"data",
                [NSNumber numberWithBool:NO], @"leaf",
                nil]];
        }
        
        delete rta;
    }
    
    root = audio;
}

- (void)probeMIDI
{
    //[root removeAllObjects];
    if( midi == nil )
    {
        midi = [NSMutableArray new];
        
        NSMutableArray * input = [[NSMutableArray new] autorelease],
        * output = [[NSMutableArray new] autorelease];
        
        [midi addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            @"Input", @"name",
            input, @"data",
            [NSNumber numberWithBool:NO], @"leaf",
            nil]];
        
        [midi addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            @"Output", @"name",
            output, @"data",
            [NSNumber numberWithBool:NO], @"leaf",
            nil]];
        
        RtMidiIn * min = NULL;
        RtMidiOut * mout = NULL;
        
        try { min = new RtMidiIn; }
        catch( RtError & err )
        {
            EM_error2b( 0, "%s", err.getMessage().c_str() );
            return;
        }
        
        t_CKUINT num = min->getPortCount();
        std::string s;
        for( t_CKUINT i = 0; i < num; i++ )
        {
            try { s = min->getPortName( i ); }
            catch( RtError & err )
        { 
                err.printMessage();
                delete min;
                return;
        }
            
            [input addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%li", i], @"name",
                [NSString stringWithUTF8String:s.c_str()], @"description",
                [NSNumber numberWithBool:YES], @"leaf",
                nil]];
        }
        
        delete min;
        
        try { mout = new RtMidiOut; }
        catch( RtError & err )
        {
            EM_error2b( 0, "%s", err.getMessage().c_str() );
            return;
        }
        
        num = mout->getPortCount();
        for( t_CKUINT i = 0; i < num; i++ )
        {
            try { s = mout->getPortName( i ); }
            catch( RtError & err )
        { 
                err.printMessage();
                delete mout;
                return;
        }
            
            [output addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithFormat:@"%li", i], @"name",
                [NSString stringWithUTF8String:s.c_str()], @"description",
                [NSNumber numberWithBool:YES], @"leaf",
                nil]];
        }
        
        delete mout;
    }
    
    root = midi;
}

- (void)probeHID
{
    //[root removeAllObjects];
    
    if( hid == nil )
    {
        hid = [NSMutableArray new];
        
        HidInManager::init();
        
        for( size_t i = 0; i < CK_HID_DEV_COUNT; i++ )
        {
            if( !default_drivers[i].count )
                continue;
            
            int count = default_drivers[i].count();
            if( count == 0 )
                continue;
            
            NSMutableArray * driver = [[NSMutableArray new] autorelease];
            
            for( int j = 0; j < count; j++ )
            {
                const char * name;
                if( default_drivers[i].name )
                    name = default_drivers[i].name( j );
                if( !name )
                    name = "(no name)";
                
                NSMutableDictionary * current_driver = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%i", j], @"name",
                    [NSString stringWithUTF8String:name], @"description",
                    [NSNumber numberWithBool:YES], @"leaf",
                    nil];

                [driver addObject:current_driver];
            }
            
            [hid addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [NSString stringWithUTF8String:default_drivers[i].driver_name], @"name",
                driver, @"data",
                [NSNumber numberWithBool:NO], @"leaf",
                nil]];
        }
    }
    
    root = hid;
}

- (void)virtualMachineDidTurnOn:(NSNotification *)n
{
    vm_on = YES;
    
    [self changeSource:source];
}

- (void)virtualMachineDidTurnOff:(NSNotification *)n
{
    vm_on = NO;
}

- (void)changeSource:(id)sender
{
    if( [[source selectedItem] tag] == 0 )
        [self probeTypes];
    
    else if( [[source selectedItem] tag] == 2 )
        [self probeAudio];
    
    else if( [[source selectedItem] tag] == 3 )
        [self probeMIDI];
    
    else if( [[source selectedItem] tag] == 4 )
        [self probeHID];
    
    [ov reloadData];
    [ov expandItem:nil expandChildren:YES];
}

- (id)outlineView:(NSOutlineView *)ov child:(int)i ofItem:(id)item
{
    if( item == nil )
        return [root objectAtIndex:i];
    return [[item objectForKey:@"data"] objectAtIndex:i];
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
    return ![[item objectForKey:@"leaf"] boolValue];
}

- (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
    if( item == nil )
        return [root count];
    return [[item objectForKey:@"data"] count];
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tc
           byItem:(id)item
{
    if( [[tc identifier] isEqualToString:@"name"] )
        return [item objectForKey:@"name"];
    
    if( [[tc identifier] isEqualToString:@"description"] )
        return [item objectForKey:@"description"];
    
    return nil;
}

@end
