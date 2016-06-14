
Motion mo;
MotionMsg momsg;

mo.open(Motion.LOCATION);
mo.open(Motion.HEADING);

while(true)
{
    mo => now;
    while(mo.recv(momsg))
    {
        if(momsg.type == Motion.LOCATION)
            <<< momsg.latitude, momsg.longitude >>>;
        else if(momsg.type == Motion.HEADING)
            <<< momsg.heading >>>;
    }
}
