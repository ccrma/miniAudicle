//
//  ChuckPadSocial.m
//  chuckpad-social-ios
//
//  Created by Mark Cerqueira on 6/17/16.
//
//

#import <Foundation/Foundation.h>
#import "ChuckPadSocial.h"
#import "AFHTTPSessionManager.h"
#import "Patch.h"
#import "FXKeychain.h"

@implementation ChuckPadSocial {

    @private
    AFHTTPSessionManager *httpSessionManager;
    NSString *baseUrl;
}

NSString *const CHUCK_PAD_SOCIAL_BASE_URL = @"https://chuckpad-social.herokuapp.com";
NSString *const CHUCK_PAD_SOCIAL_DEV_BASE_URL = @"http://localhost:9292";

NSString *const CREATE_USER_URL = @"/user/create_user";
NSString *const LOGIN_USER_URL = @"/user/login";
NSString *const CHANGE_PASSWORD_URL = @"/user/change_password";

NSString *const GET_DOCUMENTATION_URL = @"/patch/json/documentation";
NSString *const GET_FEATURED_URL = @"/patch/json/featured";
NSString *const GET_ALL_URL = @"/patch/json/all";

NSString *const CREATE_PATCH_URL = @"/patch/create_patch/";

NSString *const CHUCKPAD_SOCIAL_IOS_USER_AGENT = @"chuckpad-social-ios";

+ (ChuckPadSocial *)sharedInstance {
    static ChuckPadSocial *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ChuckPadSocial alloc] init];
        [sharedInstance initializeNetworkManager];
    });
    return sharedInstance;
}

- (void)initializeNetworkManager {
    httpSessionManager = [AFHTTPSessionManager manager];
    
    // So the service can uniquely identify iOS calls
    NSString *userAgent = [httpSessionManager.requestSerializer  valueForHTTPHeaderField:@"User-Agent"];
    userAgent = [userAgent stringByAppendingPathComponent:CHUCKPAD_SOCIAL_IOS_USER_AGENT];
    [httpSessionManager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"debugEnvironment"]) {
        baseUrl = CHUCK_PAD_SOCIAL_DEV_BASE_URL;
    } else {
        baseUrl = CHUCK_PAD_SOCIAL_BASE_URL;
    }
}

- (NSString *)getBaseUrl {
    return baseUrl;
}

- (void)toggleEnvironment {
    BOOL isDebugEnvironment;
    if ([baseUrl isEqualToString:CHUCK_PAD_SOCIAL_BASE_URL]) {
        baseUrl = CHUCK_PAD_SOCIAL_DEV_BASE_URL;
        isDebugEnvironment = YES;
    } else {
        baseUrl = CHUCK_PAD_SOCIAL_BASE_URL;
        isDebugEnvironment = NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:isDebugEnvironment forKey:@"debugEnvironment"];
}

// User API

- (void)createUser:(NSString *)username withEmail:(NSString *)email withPassword:(NSString *)password withCallback:(CreateUserCallback)callback {
    // TODO If logged in already, abort

    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, CREATE_USER_URL]];
    
    NSLog(@"createUser: %@", url.absoluteString);
    
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];
    [requestParams setObject:username forKey:@"user[username]"];
    [requestParams setObject:email forKey:@"user[email]"];
    [requestParams setObject:password forKey:@"password"];

    [httpSessionManager POST:url.absoluteString parameters:requestParams progress:nil
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         NSLog(@"createUser - response: %@", responseObject);

                         // TODO Dedupe this logic
                         int responseCode = [[responseObject objectForKey:@"code"] intValue];
                         if (responseCode == 200) {
                             // After creating a user, automatically log the user in
                             [self loginCompletedWithUsername:username withEmail:email withPassword:password];
                             callback(true, nil);
                         } else {
                             callback(false, nil);
                         }
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         NSLog(@"createUser - error: %@", error.description);
                         callback(false, nil);
                     }];
}

- (void)logIn:(NSString*)usernameOrEmail withPassword:(NSString *)password withCallback:(CreateUserCallback)callback {
    // TODO If logged in already, abort
    
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, LOGIN_USER_URL]];
    
    NSLog(@"logIn: %@", url.absoluteString);
    
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];
    [requestParams setObject:usernameOrEmail forKey:@"username_or_email"];
    [requestParams setObject:password forKey:@"password"];
    
    [httpSessionManager POST:url.absoluteString parameters:requestParams progress:nil
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         NSLog(@"Response: %@", responseObject);
                         
                         int responseCode = [[responseObject objectForKey:@"code"] intValue];
                         if (responseCode == 200) {
                             // TODO usernameOrEmail being stored twice
                             // After logging in, save the credentials
                             [self loginCompletedWithUsername:usernameOrEmail withEmail:usernameOrEmail withPassword:password];
                             callback(true, nil);
                         } else {
                             callback(false, nil);
                         }
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         NSLog(@"Error: %@", error);
                         callback(false, nil);
                     }];
}

- (void)logOut {
    // TODO If not logged in, abort

    // There is no API to log out. We just clear the credentials from the keychain which makes the user "logged out."
    [[FXKeychain defaultKeychain] setObject:nil forKey:@"username"];
    [[FXKeychain defaultKeychain] setObject:nil forKey:@"email"];
    [[FXKeychain defaultKeychain] setObject:nil forKey:@"password"];
}

- (void)changePassword:(NSString *)newPassword withCallback:(CreateUserCallback)callback {
    // TODO If logged in already, abort
    
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, CHANGE_PASSWORD_URL]];
    
    NSLog(@"changedPassword: %@", url.absoluteString);
    
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];
    [requestParams setObject:[self getLoggedInUserName] forKey:@"username_or_email"];
    [requestParams setObject:newPassword forKey:@"password"];
    
    [httpSessionManager POST:url.absoluteString parameters:requestParams progress:nil
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         NSLog(@"Response: %@", responseObject);
                         
                         int responseCode = [[responseObject objectForKey:@"code"] intValue];
                         if (responseCode == 200) {
                             // TODO Make this cleaner
                             [[FXKeychain defaultKeychain] setObject:newPassword forKey:@"password"];
                             
                             callback(true, nil);
                         } else {
                             callback(false, nil);
                         }
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         NSLog(@"Error: %@", error);
                         callback(false, nil);
                     }];
}

- (void)loginCompletedWithUsername:(NSString *)username withEmail:(NSString *)email withPassword:(NSString *)password {
    [[FXKeychain defaultKeychain] setObject:username forKey:@"username"];
    [[FXKeychain defaultKeychain] setObject:email forKey:@"email"];
    [[FXKeychain defaultKeychain] setObject:password forKey:@"password"];
}

- (NSString *)getLoggedInUserName {
    return [[FXKeychain defaultKeychain] objectForKey:@"username"];
}

- (BOOL)isLoggedIn {
    for (NSString *key in @[@"username", @"email", @"password"]) {
        if ([[FXKeychain defaultKeychain] objectForKey:key] == nil) {
            return NO;
        }
    }
    return YES;
}

// Patches API

- (void)getDocumentationPatches:(GetPatchesCallback)callback {
    [self getPatchesInternal:GET_DOCUMENTATION_URL withCallback:callback];
}

- (void)getFeaturedPatches:(GetPatchesCallback)callback {
    [self getPatchesInternal:GET_FEATURED_URL withCallback:callback];
}

- (void)getAllPatches:(GetPatchesCallback)callback {
    [self getPatchesInternal:GET_ALL_URL withCallback:callback];
}

- (void)getPatchesInternal:(NSString *)urlPath withCallback:(GetPatchesCallback)callback {
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, urlPath]];

    NSLog(@"getPatchesInternal: %@", url.absoluteString);

    [httpSessionManager GET:url.absoluteString parameters:nil progress:nil
                    success:^(NSURLSessionTask *task, id responseObject) {
                        int responseCode = [[responseObject objectForKey:@"code"] intValue];
                        if (responseCode == 200) {
                            NSMutableArray *patchesArray = [[NSMutableArray alloc] init];

                            for (id object in responseObject) {
                                Patch *patch = [[Patch alloc] initWithDictionary:object];
                                // NSLog(@"Patch: %@", patch.description);
                                [patchesArray addObject:patch];
                            }

                            callback(patchesArray, nil);
                        } else {
                            callback(nil, nil);
                        }
                    }
                    failure:^(NSURLSessionTask *operation, NSError *error) {
                        callback(nil, error);
                    }];
}

NSString *const FILE_DATA_PARAM_NAME = @"patch[data]";
NSString *const FILE_DATA_MIME_TYPE = @"application/octet-stream";

- (void)uploadPatch:(NSString *)patchName filename:(NSString *)filename fileData:(NSData *)fileData {
    [self uploadPatch:patchName isFeatured:NO isDocumentation:NO filename:filename fileData:fileData];
}

- (void)uploadPatch:(NSString *)patchName isFeatured:(BOOL)isFeatured isDocumentation:(BOOL)isDocumentation
           filename:(NSString *)filename fileData:(NSData *)fileData {
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseUrl, CREATE_PATCH_URL]];

    NSLog(@"uploadPatchWithPatchName: %@", url.absoluteString);
    
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];

    if (patchName != nil) {
        [requestParams setObject:patchName forKey:@"patch[name]"];
    }

    if (isFeatured) {
        [requestParams setObject:@"1" forKey:@"patch[featured]"];
    }

    if (isDocumentation) {
        [requestParams setObject:@"1" forKey:@"patch[documentation]"];
    }

    // TODO Callback
    [httpSessionManager POST:url.absoluteString parameters:requestParams constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:fileData
                                    name:FILE_DATA_PARAM_NAME
                                fileName:filename
                                mimeType:FILE_DATA_MIME_TYPE];
            }
             progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSLog(@"Response: %@", responseObject);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
}

@end