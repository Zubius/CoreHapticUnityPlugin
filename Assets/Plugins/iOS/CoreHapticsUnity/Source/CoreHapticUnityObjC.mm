//
//  CoreHapticUnityObjC.m
//  CoreHapticUnityObjC
//
//  Created by developer_8899 on 04/10/2019.
//  Copyright © 2019 developer_8899. All rights reserved.
//

#import "CoreHapticUnityObjC.h"

@interface CoreHapticUnityObjC()
@property (nonatomic, strong) CHHapticEngine* engine;
@property (nonatomic, strong) id<CHHapticAdvancedPatternPlayer> continuousPlayer;
@end

@implementation CoreHapticUnityObjC

static CoreHapticUnityObjC * _shared;

+ (CoreHapticUnityObjC*) shared {
    @synchronized (self) {
        if(_shared == nil) {
            _shared = [[self alloc] init];
        }
    }
    return _shared;
}

- (id) init {
    if (self == [super init]) {
        
        [self createEngine];
        
        if (self.engine != NULL) {
            [self createContinuousPlayer];
        }
    }
    return self;
}

- (void) dealloc {
    self.engine = NULL;
    self.continuousPlayer = NULL;
}

- (void) playContinuousHaptic:(float) intensity :(float)sharpness {
    if (intensity >= 1 || intensity <= 0) return;
    if (sharpness >= 1 || sharpness <= 0) return;
    
    if ([self isSupportHaptic]) {
        
        if (self.engine == NULL) {
            [self createEngine];
        }
        [self startEngine];
        
        if (self.continuousPlayer == NULL) {
            [self createContinuousPlayer];
        }
        
        [self updateContinuousHaptic:intensity :sharpness];
        
        NSError* error = nil;
        [_continuousPlayer startAtTime:0 error:&error];
        
        if (error != nil) {
            NSLog(@"Engine play continuous error --> %@", error);
        }
    }
}

- (void) playTransientHaptic:(float) intensity :(float)sharpness {
    if (intensity >= 1 || intensity <= 0) return;
    if (sharpness >= 1 || sharpness <= 0) return;
    
    if ([self isSupportHaptic]) {
        
        if (self.engine == NULL) {
            [self createEngine];
        }
        [self startEngine];
        
        CHHapticEventParameter* intensityParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:intensity];
        CHHapticEventParameter* sharpnessParam = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:sharpness];
        
        CHHapticEvent* event = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient parameters:@[intensityParam, sharpnessParam] relativeTime:0];
        
        NSError* error = nil;
        CHHapticPattern* pattern = [[CHHapticPattern alloc] initWithEvents:@[event] parameters:@[] error:&error];
        
        if (error == nil) {
            id<CHHapticPatternPlayer> player = [_engine createPlayerWithPattern:pattern error:&error];
            
            if (error == nil) {
                [player startAtTime:0 error:&error];
            } else {
                NSLog(@"Create transient player error --> %@", error);
            }
        } else {
            NSLog(@"Create transient pattern error --> %@", error);
        }
    }
}

- (void) playWithDictionaryPattern: (NSDictionary*) hapticDict {
    if ([self isSupportHaptic]) {
    
        if (self.engine == NULL) {
            [self createEngine];
        }
        [self startEngine];
        
        NSError* error = nil;
        CHHapticPattern* pattern = [[CHHapticPattern alloc] initWithDictionary:hapticDict error:&error];
        
        if (error == nil) {
            id<CHHapticPatternPlayer> player = [_engine createPlayerWithPattern:pattern error:&error];
            
            if (error == nil) {
                [player startAtTime:0 error:&error];
            } else {
                NSLog(@"Create dictionary player error --> %@", error);
            }
        } else {
            NSLog(@"Create dictionary pattern error --> %@", error);
        }
    }
}

- (void) playWithDictionaryFromJsonPattern: (NSString*) jsonDict {
    if (jsonDict != nil) {
        NSError* error = nil;
        NSData* data = [jsonDict dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (error != nil) {
            [self playWithDictionaryPattern:dict];
        } else {
            NSLog(@"Create dictionary from json error --> %@", error);
        }
    } else {
        NSLog(@"Json dictionary string is nil");
    }
}

- (void) playWIthAHAPFile: (NSString*) fileName {
    if ([self isSupportHaptic]) {
    
        if (self.engine == NULL) {
            [self createEngine];
        }
        [self startEngine];
        
        NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"ahap"];
        [self playWithAHAPFileFromURLAsString:path];
    }
}

- (void) playWithAHAPFileFromURLAsString: (NSString*) urlAsString {
    if (urlAsString != nil) {
        NSURL* url = [NSURL fileURLWithPath:urlAsString];
        [self playWithAHAPFileFromURL:url];
    } else {
        NSLog(@"url string is nil");
    }
}

- (void) playWithAHAPFileFromURL: (NSURL*) url {
    NSError * error = nil;
    [_engine playPatternFromURL:url error:&error];
    
    if (error != nil) {
        NSLog(@"Engine play from AHAP file error --> %@", error);
    }
}

- (void) updateContinuousHaptic:(float) intensity :(float)sharpness {
    if (intensity >= 1 || intensity <= 0) return;
    if (sharpness >= 1 || sharpness <= 0) return;
    
    if ([self isSupportHaptic]) {
        if (self.engine == NULL) {
            [self createEngine];
        }
        [self startEngine];
        
        if (self.continuousPlayer == NULL) {
            [self createContinuousPlayer];
        }
        
        CHHapticDynamicParameter* intensityParam = [[CHHapticDynamicParameter alloc] initWithParameterID:CHHapticDynamicParameterIDHapticIntensityControl value:intensity relativeTime:0];
        CHHapticDynamicParameter* sharpnessParam = [[CHHapticDynamicParameter alloc] initWithParameterID:CHHapticDynamicParameterIDHapticSharpnessControl value:sharpness relativeTime:0];
        
        NSError* error = nil;
        [_continuousPlayer sendParameters:@[intensityParam, sharpnessParam] atTime:0 error:&error];
        
        if (error != nil) {
            NSLog(@"Update contuous parameters error --> %@", error);
        }
    }
}

- (void) stop {
    if ([self isSupportHaptic]) {
        
        NSError* error = nil;
        [_continuousPlayer stopAtTime:0 error:&error];
    }
};

- (void) createContinuousPlayer {
    if ([self isSupportHaptic]) {
        CHHapticEventParameter* intensity = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:1.0];
        CHHapticEventParameter* sharpness = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:0.5];
        
        CHHapticEvent* event = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticContinuous parameters:@[intensity, sharpness] relativeTime:0 duration:30];
        
        NSError* error = nil;
        CHHapticPattern* pattern = [[CHHapticPattern alloc] initWithEvents:@[event] parameters:@[] error:&error];
        
        if (error == nil) {
            _continuousPlayer = [_engine createAdvancedPlayerWithPattern:pattern error:&error];
        } else {
            NSLog(@"Create contuous player error --> %@", error);
        }
    }
}

- (void) createEngine {
    if ([self isSupportHaptic]) {
        NSError* error = nil;
        _engine = [[CHHapticEngine alloc] initAndReturnError:&error];
        
        if (error == nil) {
            
            _engine.playsHapticsOnly = true;
            
            _engine.stoppedHandler = ^(CHHapticEngineStoppedReason reason) {
                NSLog(@"The engine stopped for reason: %ld", (long)reason);
                switch (reason) {
                    case CHHapticEngineStoppedReasonAudioSessionInterrupt:
                        NSLog(@"Audio session interrupt");
                        break;
                    case CHHapticEngineStoppedReasonApplicationSuspended:
                        NSLog(@"Application suspended");
                        break;
                    case CHHapticEngineStoppedReasonIdleTimeout:
                        NSLog(@"Idle timeout");
                        break;
                    case CHHapticEngineStoppedReasonSystemError:
                        NSLog(@"System error");
                        break;
                    case CHHapticEngineStoppedReasonNotifyWhenFinished:
                        NSLog(@"Playback finished");
                        break;
                    
                    default:
                        NSLog(@"Unknown error");
                        break;
                }
            };
            
            __weak typeof(self) weakSelf = self;
            _engine.resetHandler = ^{
                [weakSelf startEngine];
            };
        } else {
            NSLog(@"Engine init error --> %@", error);
        }
    }
}

- (void) startEngine {
    NSError* reseterror = nil;
    [_engine startAndReturnError:&reseterror];
    
    if (reseterror != nil) {
        NSLog(@"Engine reset error --> %@", reseterror);
    }
}

- (BOOL) isSupportHaptic {
    if ([CoreHapticUnityObjC isSupported]) {
        return CHHapticEngine.capabilitiesForHardware.supportsHaptics;
    }
    return NO;
}

+ (BOOL) isSupported {
    if (@available(iOS 13, *)) {
        return YES;
    }
    return NO;
}

- (NSString*) createNSString: (const char*) string {
  if (string)
      return [NSString stringWithUTF8String: string];
  else
      return [NSString stringWithUTF8String: ""];
}

@end


#pragma mark - Bridge

extern "C" {
    void _coreHapticsUnityPlayContinuous(float intensity, float sharpness) {
        [[CoreHapticUnityObjC shared] playContinuousHaptic:intensity :sharpness];
    }
//
    void _coreHapticsUnityPlayTransient(float intensity, float sharpness) {
        [[CoreHapticUnityObjC shared] playTransientHaptic:intensity :sharpness];
    }

    void _coreHapticsUnityStop() {
        [[CoreHapticUnityObjC shared] stop];
    }

    void _coreHapticsUnityupdateContinuousHaptics(float intensity, float sharpness) {
        [[CoreHapticUnityObjC shared] updateContinuousHaptic:intensity :sharpness];
    }

    void _coreHapticsUnityplayWithDictionaryPattern(const char* jsonDict) {
        [[CoreHapticUnityObjC shared] playWithDictionaryFromJsonPattern:[[CoreHapticUnityObjC shared] createNSString:jsonDict]];
    }

    void _coreHapticsUnityplayWIthAHAPFile(const char* filename) {
        [[CoreHapticUnityObjC shared] playWIthAHAPFile:[[CoreHapticUnityObjC shared] createNSString:filename]];
    }

    void _coreHapticsUnityplayWithAHAPFileFromURLAsString(const char* urlAsString) {
        [[CoreHapticUnityObjC shared] playWithAHAPFileFromURLAsString:[[CoreHapticUnityObjC shared] createNSString:urlAsString]];
    }
    
    bool _coreHapticsUnityIsSupport() {
        return [CoreHapticUnityObjC isSupported];
    }
}
