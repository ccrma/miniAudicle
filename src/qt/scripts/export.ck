
//cherr <= "export.ck" <= IO.nl();

"/" + me.arg(0) @=> string ckFilename;
"/" + me.arg(1) @=> string wavFilename;
me.arg(2) => Std.atoi => int doLimit;
me.arg(3) => Std.atof => float limit;

dac => WvOut2 w => blackhole;
wavFilename => w.wavFilename;
.5 => w.fileGain;

// temporary workaround to automatically close file on remove-shred
null @=> w;

Machine.add(ckFilename) => int shredId;

if(doLimit)
{
    limit::second => now;
    
    Machine.remove(shredId);
}
else
{
    Shred.fromId(shredId) @=> Shred shred;
    while(!shred.done())
    {
        1::second => now;
    }
}
