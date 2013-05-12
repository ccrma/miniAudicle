
OnePole left => blackhole;
OnePole right => blackhole;
3 => left.op => right.op;
0.125 => float tau;
second/samp => float srate;
Math.pow(1.0/Math.e, 1.0/(tau*srate)) => left.pole => right.pole;

if(dac.channels() > 0)
{
    dac.chan(0) => left;
    dac.chan(0) => left;
}

if(dac.channels() > 1)
{
    dac.chan(1) => right;
    dac.chan(1) => right;
}
else
{
    left @=> right;
}

while( true )
{
    left.last() => mARecordSession.leftVU;
    right.last() => mARecordSession.rightVU;
    20::ms => now;
}
