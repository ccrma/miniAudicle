//
//  ulib_motion.cpp
//  miniAudicle
//
//  Created by Spencer Salazar on 9/17/14.
//
//

#include "ulib_motion.h"
#include "chuck_vm.h"
#include "chuck_globals.h"
#include "util_buffers.h"

#import <CoreMotion/CoreMotion.h>

/* member vars for MotionMsg */
static t_CKUINT motionmsg_mvar_timestamp = 0;
static t_CKUINT motionmsg_mvar_type = 0;
static t_CKUINT motionmsg_mvar_x = 0;
static t_CKUINT motionmsg_mvar_y = 0;
static t_CKUINT motionmsg_mvar_z = 0;
static t_CKUINT motionmsg_mvar_heading = 0;
static t_CKUINT motionmsg_mvar_latitude = 0;
static t_CKUINT motionmsg_mvar_longitude = 0;

/* static vars for Motion types */
static t_CKINT MOTIONTYPE_NONE     = 0;
static t_CKINT MOTIONTYPE_ACCEL    = 1;
static t_CKINT MOTIONTYPE_GYRO     = 2;
static t_CKINT MOTIONTYPE_MAG      = 3;
static t_CKINT MOTIONTYPE_ATTITUDE = 4;
static t_CKINT MOTIONTYPE_HEADING  = 5;
static t_CKINT MOTIONTYPE_LOCATION = 6;

/* member functions for Motion */
CK_DLL_CTOR(motion_ctor);
CK_DLL_DTOR(motion_dtor);
CK_DLL_MFUN(motion_start);
CK_DLL_MFUN(motion_stop);
CK_DLL_MFUN(motion_stop_all);
CK_DLL_MFUN(motion_recv);

/* member vars for Motion */
static t_CKUINT motion_mvar_manager = 0;
static t_CKUINT motion_mvar_queue = 0;


t_CKBOOL motion_query( Chuck_Env *env )
{
    Chuck_DL_Func * func = NULL;
    
    // log
    EM_log( CK_LOG_INFO, "class 'Motion'" );
    
    std::string doc;
    
    // import
    doc = "Holds a single sample of sensor data. ";
    if( !type_engine_import_class_begin(env, "MotionMsg", "Object", env->global(),
                                        NULL, NULL, doc.c_str()))
        return FALSE;
    
    doc = "Type of the sensor data. ";
    motionmsg_mvar_type = type_engine_import_mvar( env, "int", "type", FALSE, doc.c_str() );
    if( motionmsg_mvar_type == CK_INVALID_OFFSET ) goto error;
    
    doc = "Time corresponding to this sample. ";
    motionmsg_mvar_timestamp = type_engine_import_mvar( env, "time", "timestamp", FALSE, doc.c_str() );
    if( motionmsg_mvar_timestamp == CK_INVALID_OFFSET ) goto error;
    
    doc = "x-coordinate of this sample. Valid for accelerometer, gyroscope, magnetometer, or attitude samples only.";
    motionmsg_mvar_x = type_engine_import_mvar( env, "float", "x", FALSE, doc.c_str() );
    if( motionmsg_mvar_x == CK_INVALID_OFFSET ) goto error;
    
    doc = "y-coordinate of this sample. Valid for accelerometer, gyroscope, magnetometer, or attitude samples only.";
    motionmsg_mvar_y = type_engine_import_mvar( env, "float", "y", FALSE, doc.c_str() );
    if( motionmsg_mvar_y == CK_INVALID_OFFSET ) goto error;
    
    doc = "z-coordinate of this sample. Valid for accelerometer, gyroscope, magnetometer, or attitude samples only.";
    motionmsg_mvar_z = type_engine_import_mvar( env, "float", "z", FALSE, doc.c_str() );
    if( motionmsg_mvar_z == CK_INVALID_OFFSET ) goto error;
    
    doc = "Heading of this sample, in degrees clockwise from magnetic north. Valid for compass heading samples only.";
    motionmsg_mvar_heading = type_engine_import_mvar( env, "float", "heading", FALSE, doc.c_str() );
    if( motionmsg_mvar_heading == CK_INVALID_OFFSET ) goto error;
    
    doc = "Latitude of this sample. Valid for location samples only.";
    motionmsg_mvar_latitude = type_engine_import_mvar( env, "float", "latitude", FALSE, doc.c_str() );
    if( motionmsg_mvar_latitude == CK_INVALID_OFFSET ) goto error;
    
    doc = "Longitude of this sample. Valid for location samples only.";
    motionmsg_mvar_longitude = type_engine_import_mvar( env, "float", "longitude", FALSE, doc.c_str() );
    if( motionmsg_mvar_longitude == CK_INVALID_OFFSET ) goto error;
    
    // end the class import
    type_engine_import_class_end( env );
    
    // import
    doc = "Provides data from the various sensors of the host mobile device.";
    if( !type_engine_import_class_begin(env, "Motion", "Event", env->global(),
                                        motion_ctor, motion_dtor, doc.c_str()))
        return FALSE;
    
    //
    doc = "No sensor type specified.";
    if( !type_engine_import_svar(env, "int", "NONE", TRUE,
                                 (t_CKUINT) &MOTIONTYPE_NONE, doc.c_str() ) )
        goto error;
    
    //
    doc = "Accelerometer.";
    if( !type_engine_import_svar(env, "int", "ACCEL", TRUE,
                                 (t_CKUINT) &MOTIONTYPE_ACCEL, doc.c_str() ) )
        goto error;
    
    //
    doc = "Gyroscope.";
    if( !type_engine_import_svar(env, "int", "GYRO", TRUE,
                                 (t_CKUINT) &MOTIONTYPE_GYRO, doc.c_str() ) )
        goto error;
    
    //
    doc = "Magnetometer.";
    if( !type_engine_import_svar(env, "int", "MAG", TRUE,
                                 (t_CKUINT) &MOTIONTYPE_MAG, doc.c_str() ) )
        goto error;
    
    //
    doc = "Attitude.";
    if( !type_engine_import_svar(env, "int", "ATTITUDE", TRUE,
                                 (t_CKUINT) &MOTIONTYPE_ATTITUDE, doc.c_str() ) )
        goto error;
    
    //
    doc = "Compass heading.";
    if( !type_engine_import_svar(env, "int", "HEADING", TRUE,
                                 (t_CKUINT) &MOTIONTYPE_HEADING, doc.c_str() ) )
        goto error;
    
    //
    doc = "Geographic location.";
    if( !type_engine_import_svar(env, "int", "LOCATION", TRUE,
                                 (t_CKUINT) &MOTIONTYPE_LOCATION, doc.c_str() ) )
        goto error;
    
    // private mvar
    motion_mvar_manager = type_engine_import_mvar( env, "int", "@mgr", FALSE, NULL );
    if( motion_mvar_manager == CK_INVALID_OFFSET ) goto error;
    
    // private mvar
    motion_mvar_queue = type_engine_import_mvar( env, "int", "@queue", FALSE, NULL );
    if( motion_mvar_queue == CK_INVALID_OFFSET ) goto error;
    
    // add start()
    doc = "Start generating input from the specified sensor. ";
    func = make_new_mfun( "int", "open", motion_start );
    func->add_arg("int", "type");
    func->doc = doc;
    if( !type_engine_import_mfun( env, func ) ) goto error;
    
    // add stop()
    doc = "Stop generating input from all sensors. ";
    func = make_new_mfun( "void", "close", motion_stop_all );
    func->doc = doc;
    if( !type_engine_import_mfun( env, func ) ) goto error;
    
    // add stop()
    doc = "Stop generating input from the specified sensor. ";
    func = make_new_mfun( "void", "close", motion_stop );
    func->add_arg("int", "type");
    func->doc = doc;
    if( !type_engine_import_mfun( env, func ) ) goto error;
    
    // add recv()
    doc = "Receive the next sample of sensor data. ";
    func = make_new_mfun( "int", "recv", motion_recv );
    func->add_arg("MotionMsg", "type");
    func->doc = doc;
    if( !type_engine_import_mfun( env, func ) ) goto error;
    
    // end the class import
    type_engine_import_class_end( env );
    
    return TRUE;
    
error:
    
    // end the class import
    type_engine_import_class_end( env );
    
    return FALSE;
}

struct MotionMsg
{
    MotionMsg()
    {
        memset(this, 0, sizeof(MotionMsg));
        type = MOTIONTYPE_NONE;
    }
    
    MotionMsg(t_CKINT _type, t_CKTIME _timestamp, t_CKFLOAT _x, t_CKFLOAT _y, t_CKFLOAT _z)
    {
        type = _type;
        timestamp = _timestamp;
        x = _x;
        y = _y;
        z = _z;
    }
    
    MotionMsg(t_CKINT _type, t_CKTIME _timestamp, t_CKFLOAT _heading)
    {
        type = _type;
        timestamp = _timestamp;
        heading = _heading;
    }
    
    MotionMsg(t_CKINT _type, t_CKTIME _timestamp, t_CKFLOAT _latitude, t_CKFLOAT _longitude)
    {
        type = _type;
        timestamp = _timestamp;
        location.latitude = _latitude;
        location.longitude = _longitude;
    }
    
    t_CKINT type;
    t_CKTIME timestamp;
    
    union
    {
        struct
        {
            t_CKFLOAT x, y, z;
        };
        
        t_CKFLOAT heading;
        
        struct
        {
            t_CKFLOAT latitude, longitude;
        } location;
    };
};

@interface mAMotionManager : NSObject

- (id)initWithVM:(Chuck_VM *)vm;
- (void)startAccelerometer:(Chuck_Event *)event toQueue:(CircularBuffer<MotionMsg> *)queue;
- (void)startGyroscope:(Chuck_Event *)event toQueue:(CircularBuffer<MotionMsg> *)queue;
- (void)stop:(Chuck_Event *)event onCompletion:(void (^)())completion;

@end

mAMotionManager *g_motionManager = nil;

CK_DLL_CTOR(motion_ctor)
{
    if(g_motionManager == nil)
        g_motionManager = [[mAMotionManager alloc] initWithVM:SHRED->vm_ref];
    OBJ_MEMBER_INT(SELF, motion_mvar_queue) = (t_CKINT) new CircularBuffer<MotionMsg>(32);
}

CK_DLL_DTOR(motion_dtor)
{
    assert(g_motionManager);
    
    CircularBuffer<MotionMsg> *queue = (CircularBuffer<MotionMsg> *) OBJ_MEMBER_INT(SELF, motion_mvar_queue);
    OBJ_MEMBER_INT(SELF, motion_mvar_queue) = NULL;
    
    [g_motionManager stop:(Chuck_Event *)SELF onCompletion:^{
        if(queue)
            delete queue;
    }];
}

CK_DLL_MFUN(motion_start)
{
    assert(g_motionManager);
    
    CircularBuffer<MotionMsg> *queue = (CircularBuffer<MotionMsg> *) OBJ_MEMBER_INT(SELF, motion_mvar_queue);
    t_CKINT type = GET_NEXT_INT(ARGS);
    
    if(type == MOTIONTYPE_ACCEL)
        [g_motionManager startAccelerometer:(Chuck_Event *)SELF toQueue:queue];
    
    RETURN->v_int = 1;
}

CK_DLL_MFUN(motion_stop)
{
}

CK_DLL_MFUN(motion_stop_all)
{
}

CK_DLL_MFUN(motion_recv)
{
    Chuck_Object *msgobj = GET_NEXT_OBJECT(ARGS);
    CircularBuffer<MotionMsg> *queue = (CircularBuffer<MotionMsg> *) OBJ_MEMBER_INT(SELF, motion_mvar_queue);

    MotionMsg msg;
    
    int gotit = queue->get(msg);
    if(gotit)
    {
        OBJ_MEMBER_INT(msgobj, motionmsg_mvar_type) = msg.type;
        OBJ_MEMBER_TIME(msgobj, motionmsg_mvar_timestamp) = msg.timestamp;
        
        if(msg.type == MOTIONTYPE_ACCEL || msg.type == MOTIONTYPE_GYRO ||
           msg.type == MOTIONTYPE_MAG || msg.type == MOTIONTYPE_ATTITUDE)
        {
            OBJ_MEMBER_FLOAT(msgobj, motionmsg_mvar_x) = msg.x;
            OBJ_MEMBER_FLOAT(msgobj, motionmsg_mvar_y) = msg.y;
            OBJ_MEMBER_FLOAT(msgobj, motionmsg_mvar_z) = msg.z;
        }
    }
    
    RETURN->v_int = gotit;
}


@interface mAMotionManager ()
{
    dispatch_queue_t _dispatchQueue;
    NSOperationQueue *_queue;
    Chuck_VM *_vm;
    CBufferSimple *_eventBuffer;
    
    std::list<Chuck_Event *> _accelListeners;
    std::map<Chuck_Event *, CircularBuffer<MotionMsg> *> _messageQueue;
}

@property (strong, nonatomic) CMMotionManager *motionManager;

- (void)_updateAccelerometer:(CMAccelerometerData *)accelerometerData;

@end


@implementation mAMotionManager

- (CMMotionManager *)motionManager
{
    if(_motionManager == nil)
        _motionManager = [CMMotionManager new];
    return _motionManager;
}

- (id)initWithVM:(Chuck_VM *)vm;
{
    if(self = [super init])
    {
        _dispatchQueue = dispatch_queue_create("mAMotionManager", DISPATCH_QUEUE_SERIAL);
        _queue = [NSOperationQueue new];
        [_queue setUnderlyingQueue:_dispatchQueue];
        
        _vm = vm;
        _eventBuffer = vm->create_event_buffer();
    }
    
    return self;
}

- (void)startAccelerometer:(Chuck_Event *)event toQueue:(CircularBuffer<MotionMsg> *)queue
{
    dispatch_async(_dispatchQueue, ^{
        _accelListeners.push_back(event);
        _messageQueue[event] = queue;
    });
    
    if(!self.motionManager.accelerometerActive)
    {
        [self.motionManager startAccelerometerUpdatesToQueue:_queue
                                                 withHandler:^(CMAccelerometerData * _Nullable accelerometerData,
                                                               NSError * _Nullable error) {
                                                     [self _updateAccelerometer:accelerometerData];
                                                 }];
    }
}

- (void)_updateAccelerometer:(CMAccelerometerData *)accelerometerData
{
    CMAcceleration accel = accelerometerData.acceleration;
    MotionMsg msg(MOTIONTYPE_ACCEL, 0, accel.x, accel.y, accel.z);
    
    for(auto event : _accelListeners)
    {
        if(_messageQueue.count(event) != 0 && _messageQueue[event])
            _messageQueue[event]->put(msg);
        event->queue_broadcast(_eventBuffer);
    }
}

- (void)startGyroscope:(Chuck_Event *)event toQueue:(CircularBuffer<MotionMsg> *)queue
{
    
}

- (void)stop:(Chuck_Event *)event onCompletion:(void (^)())completion
{
    dispatch_async(_dispatchQueue, ^{
        _accelListeners.remove(event);
        _messageQueue.erase(event);
        
        if(completion)
            completion();
        
        if(_accelListeners.size() == 0)
            [self.motionManager stopAccelerometerUpdates];
    });
}

@end



