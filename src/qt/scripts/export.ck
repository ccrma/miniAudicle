
//cherr <= "export.ck" <= IO.nl();

me.arg(0) @=> string ckFilename;
me.arg(1) @=> string wavFilename;
me.arg(2) => Std.atoi => int doLimit;
me.arg(3) => Std.atof => float limit;

dac => WvOut2 w => blackhole;
wavFilename => w.wavFilename;
.5 => w.fileGain;

// temporary workaround to automatically close file on remove-shred
// 1.5.4.2 -- no longer need to do this due to new UGen GC policy
// (in fact, under the new policy this would not record anything)
// null @=> w;

// escape : (for Windows)
for(int i; i < ckFilename.length(); i++)
{
    if(ckFilename.charAt(i) == ':')
    {
        ckFilename.replace(i, 1, "\\:");
        i++;
    }
}

Machine.add(ckFilename) => int shredId;

if(doLimit)
{
    limit::second => now;
    Machine.shreds() @=> int shreds[];
    for(int i; i < shreds.size(); i++)
    {
        if(shreds[i] != me.id())
            Machine.remove(shreds[i]);
    }
}
else
{
    Machine.shreds() @=> int shreds[];
    while(shreds.size() > 1)
    {
        1::second => now;
        Machine.shreds() @=> shreds;
    }
}

//<<< "export exit" >>>;
