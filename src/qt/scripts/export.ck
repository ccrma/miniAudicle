// name: export.ck
// desc: miniAudicle export tool
// author: Spencer Salazar

// arguments
me.arg(0) => string ckFilename;
me.arg(1) => string wavFilename;
me.arg(2) => Std.atoi => int doLimit;
me.arg(3) => Std.atof => float limit;

// debug print
// cherr <= "export.ck" <= IO.nl();
// <<< "export.ck:", me.arg(0) + ":" + me.arg(1) + ":" + me.arg(2) + ":" + limit >>>;

// capture dac into stereo WvOut
dac => WvOut2 w => blackhole;
// set filename
wavFilename => w.wavFilename;
// set gain
.5 => w.fileGain;

// temporary workaround to automatically close file on remove-shred
// 1.5.4.2 -- no longer need to do this due to new UGen GC policy
// (in fact, under the new policy this would not record anything)
// null @=> w;

// run the file
ckFilename => ckEscape => Machine.add => int shredId;

// yield current shred (let what we just added to start running)
// ...before we enter into the duration logic below
me.yield();

// check which mode
if( doLimit ) // pre-specified export duration
{
    // let time pass for pre-specified export duration
    limit::second => now;

    // get list of shreds in VM
    Machine.shreds() @=> int shreds[];
    for( int s : shreds )
    {
        // remove all shreds except me
        if( s != me.id() ) Machine.remove( s );
    }
}
else // no pre-specified export duration
{
    // as long as there are other shreds running
    while( Machine.numShreds() > 1 )
    {
        // let time pass
        1::second => now;
    }
}

// escape filename
fun string ckEscape( string _s )
{
    // empty string
    if( _s.length() == 0 ) return "";

    _s.substring(0) => string s;
    // escape :
    for(int i; i < s.length(); i++)
    {
        if(s.charAt(i) == ':')
        {
            s.replace(i, 1, "\\:");
            i++;
        }
    }

    return s;
}
