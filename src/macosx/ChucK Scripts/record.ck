
me.arg(0) => string location;
me.arg(1) => string filename;

dac => WvOut2 w => blackhole;
if(filename == "special:auto")
{
    location + "/chuck-session" => w.autoPrefix;
    "special:auto" => w.wavFilename;
}
else
{
    location + "/" + filename => w.wavFilename;
}
.5 => w.fileGain;

// temporary workaround to automatically close file on remove-shred
null @=> w;

while( true ) 1::second => now;

