//
//  CoreHapticUnityObjC.h
//  CoreHapticUnityObjC
//
//  Created by developer_8899 on 04/10/2019.
//  Copyright © 2019 developer_8899. All rights reserved.
//
#ifndef CoreHapticUnityObjC_h
#define CoreHapticUnityObjC_h

#import <Foundation/Foundation.h>
#import <CoreHaptics/CoreHaptics.h>

typedef void (*hapticCallback)(int);

@interface CoreHapticUnityObjC : NSObject {

}

+ (CoreHapticUnityObjC*) shared;
- (void) playContinuousHaptic:(float) intensity :(float) sharpness :(float)duration;
- (void) playTransientHaptic:(float) intensity :(float) sharpness;
- (void) playWithDictionaryFromJsonPattern: (NSString*) jsonDict;
- (void) playWIthAHAPFile: (NSString*) fileName;
- (void) playWithAHAPFileFromURLAsString: (NSString*) urlAsString;
- (void) stop;
- (void) stopPatternPlayer;
- (void) updateContinuousHaptic:(float) intensity :(float) sharpness;
+ (BOOL) isSupportHaptic;
+ (void) registerCallbacks:(hapticCallback) patternFinishedCallback :(hapticCallback) engineStoppedCallback;

@end

#endif
