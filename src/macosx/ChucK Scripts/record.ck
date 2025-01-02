// global event to be broadcasted by miniAudicle
global Event MINIAUDICLE_GLOBAL_EVENT_RECORDING;

// arguments
me.arg(0) => string location;
me.arg(1) => string filename;

// recording
dac => WvOut2 w => blackhole;

// check filename
if( filename == "special:auto" )
{
    // auto filename
    location + "/chuck-session" => w.autoPrefix;
    "special:auto" => w.wavFilename;
}
else
{
    // explicit filename
    location + "/" + filename => w.wavFilename;
}

// set gain
.5 => w.fileGain;

// temporary workaround to automatically close file on remove-shred
// 1.5.4.4 -- no longer need to do this due to new UGen GC policy
// (in fact, under the new policy this would not record anything)
// null @=> w;

// 1.5.4.4 -- time-loop replaced with global event
// currently, VM shred removal does not unwind the call stack
// and thus `w` is not cleaned up and the output file is not
// flushed and closed
// while( true ) 1::second => now;

// wait for miniAudicle to broad to stop recording
MINIAUDICLE_GLOBAL_EVENT_RECORDING => now;
// after this point, `w` should go out of scope and clean up
