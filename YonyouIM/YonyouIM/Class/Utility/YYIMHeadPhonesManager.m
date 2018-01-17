//
//  YYIMHeadPhonesManager.m
//  YonyouIM
//
//  Created by yanghaoc on 16/3/30.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMHeadPhonesManager.h"
#import <AVFoundation/AVFoundation.h>
#import "YYIMUIDefs.h"
#import "YYIMLogger.h"

@interface YYIMHeadPhonesManager ()

@property (nonatomic, assign) BOOL inNetMeeting;

@end

@implementation YYIMHeadPhonesManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netMeetingStateChange:) name:YYIM_NOTIFICATION_NETMEETING_STATE_CHANGE object:nil];
    }
    
    return self;
}

- (BOOL)HeadPhoneEnable {
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    
    YYIMLogDebug(@"current outputs:%@",[route outputs]);
    
    for (AVAudioSessionPortDescription *desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    
    return NO;
}

- (void)routeChange:(NSNotification *)notification {
    BOOL headEnable = [self HeadPhoneEnable];
    
    YYIMLogDebug(@"headphone-route变化，是否存在耳机:%@",headEnable ? @"YES" : @"NO");
    
    if (headEnable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:YYIM_NOTIFICATION_HEADPHONE_CHANGE object:@YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:YYIM_NOTIFICATION_HEADPHONE_CHANGE object:@NO];
    }
    
    if (!self.inNetMeeting) {
        [self updateAudioPortOverride];
    }
}

- (void)updateAudioPortOverride {
    AVAudioSession* session = [AVAudioSession sharedInstance];
    BOOL success;
    NSError* error;
    
    BOOL headEnable = [self HeadPhoneEnable];
    
    AVAudioSessionPortOverride override = headEnable ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker;
    YYIMLogDebug(@"overrideOutputAudioPort:%@", headEnable ? @"使用內声道" : @"使用扬声器");
    success = [session overrideOutputAudioPort:override
                                         error:&error];
    if (!success)  YYIMLogError(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    success = [session setActive:YES error:&error];
    if (!success) YYIMLogError(@"AVAudioSession error activating: %@",error);
}
 
- (void)netMeetingStateChange:(NSNotification *)notification {
    self.inNetMeeting = [notification.object boolValue];
    
    if (!self.inNetMeeting) {
        [self updateAudioPortOverride];
    }
}

@end
