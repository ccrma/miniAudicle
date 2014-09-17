//
//  ulib_motion.cpp
//  miniAudicle
//
//  Created by Spencer Salazar on 9/17/14.
//
//

#include "ulib_motion.h"
#import <CoreMotion/CoreMotion.h>


CK_DLL_SFUN(motion_start);
CK_DLL_SFUN(motion_stop);
CK_DLL_SFUN(motion_accelX);
CK_DLL_SFUN(motion_accelY);
CK_DLL_SFUN(motion_accelZ);


t_CKBOOL motion_query( Chuck_Env *env )
{
    Chuck_DL_Func * func = NULL;
    
    // log
    EM_log( CK_LOG_INFO, "class 'Motion'" );
    
    // import
    if( !type_engine_import_class_begin( env, "Motion", "Object",
                                        env->global(), NULL,
                                        NULL ) )
        return FALSE;
    
    // add start()
    func = make_new_sfun( "void", "start", motion_start );
    if( !type_engine_import_sfun( env, func ) ) goto error;
    
    // add stop()
    func = make_new_sfun( "void", "stop", motion_stop );
    if( !type_engine_import_sfun( env, func ) ) goto error;
    
    // add accelX()
    func = make_new_sfun( "float", "accelX", motion_accelX );
    if( !type_engine_import_sfun( env, func ) ) goto error;
    
    // add accelY()
    func = make_new_sfun( "float", "accelY", motion_accelY );
    if( !type_engine_import_sfun( env, func ) ) goto error;
    
    // add accelZ()
    func = make_new_sfun( "float", "accelZ", motion_accelZ );
    if( !type_engine_import_sfun( env, func ) ) goto error;
    
    // end the class import
    type_engine_import_class_end( env );
    
    return TRUE;
    
error:
    
    // end the class import
    type_engine_import_class_end( env );
    
    return FALSE;
}

CMMotionManager *g_motionManager = nil;

CK_DLL_SFUN(motion_start)
{
    if(g_motionManager == nil)
    {
        g_motionManager = [CMMotionManager new];
    }
    
    [g_motionManager startAccelerometerUpdates];
}

CK_DLL_SFUN(motion_stop)
{
    [g_motionManager stopAccelerometerUpdates];
}

CK_DLL_SFUN(motion_accelX)
{
    if(g_motionManager == nil)
    {
        RETURN->v_float = 0;
        return;
    }
    
    CMAccelerometerData *accelData = g_motionManager.accelerometerData;
    RETURN->v_float = accelData.acceleration.x;
}

CK_DLL_SFUN(motion_accelY)
{
    if(g_motionManager == nil)
    {
        RETURN->v_float = 0;
        return;
    }
    
    CMAccelerometerData *accelData = g_motionManager.accelerometerData;
    RETURN->v_float = accelData.acceleration.y;
}

CK_DLL_SFUN(motion_accelZ)
{
    if(g_motionManager == nil)
    {
        RETURN->v_float = 0;
        return;
    }
    
    CMAccelerometerData *accelData = g_motionManager.accelerometerData;
    RETURN->v_float = accelData.acceleration.z;
}


