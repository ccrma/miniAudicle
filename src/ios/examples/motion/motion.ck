
Motion mo;
MotionMsg momsg;

mo.open(Motion.ATTITUDE);

while(true)
{
    mo => now;
    while(mo.recv(momsg))
    {
        <<< momsg.x, momsg.y, momsg.z >>>;
    }
}
