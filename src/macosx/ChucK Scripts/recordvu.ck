
0.11 => float tau;
60 => float dbrange;

OnePole left => blackhole;
OnePole right => blackhole;
3 => left.op => right.op;
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
    left.last() => lin2dbnorm => mARecordSession.leftVU;
    right.last() => lin2dbnorm => mARecordSession.rightVU;
    20::ms => now;
}

fun float lin2dbnorm(float lin)
{
    if(lin == 0) return 0.0;
    
    10*Math.log10(lin) => float db;
    (dbrange+db)/dbrange => float dbnorm;
    return dbnorm;
}
