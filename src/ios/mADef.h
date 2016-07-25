//
//  mADef.h
//  miniAudicle
//
//  Created by Spencer Salazar on 4/21/14.
//
//

#ifndef miniAudicle_mADef_h
#define miniAudicle_mADef_h

#define G_RATIO (1.61803398875)

//#ifdef DEBUG
//#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
//#   define DLog() NSLog((@"%s [Line %d] "), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
//#else
//#   define DLog(...)
//#endif
//
//// ALog always displays output regardless of the DEBUG setting
//#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
//#define ALog() NSLog((@"%s [Line %d] "), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define NSLogThisFun() NSLog((@"%s [Line %d] "), __PRETTY_FUNCTION__, __LINE__)
#define NSLogFun(fmt, ...) NSLog((@"%s: " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__)

#define BETA 1

#endif
