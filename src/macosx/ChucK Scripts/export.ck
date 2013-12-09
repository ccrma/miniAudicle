
//cherr <= "export.ck" <= IO.nl();

me.arg(0) => string ckFilename;
me.arg(1) => string wavFilename;
me.arg(2) => Std.atoi => int doLimit;
me.arg(3) => Std.atof => float limit;

//<<< "export.ck:", me.arg(0) + ":" + me.arg(1) + ":" + me.arg(2) + ":" + limit >>>;

dac => WvOut2 w => blackhole;
wavFilename => w.wavFilename;
.5 => w.fileGain;

// temporary workaround to automatically close file on remove-shred
null @=> w;

ckFilename => ckEscape => Machine.add => int shredId;

me.yield();

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

fun string ckEscape(string _s)
{
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
