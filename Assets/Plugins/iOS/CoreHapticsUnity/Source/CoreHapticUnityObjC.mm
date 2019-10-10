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
@property (nonatomic) BOOL isEngineStarted;
@end

@implementation CoreHapticUnityObjC

static CoreHapticUnityObjC * _shared;
static hapticCallback onHapticFinished = NULL;

+ (CoreHapticUnityObjC*) shared {
    @synchronized (self) {
        if(_shared == nil) {
            _shared = [[self alloc] init];
        }
    }
    return _shared;
}

+ (void) registerCallback:(hapticCallback) callback
{
    onHapticFinished = callback;
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
  #if DEBUG
      NSLog(@"[CoreHapticUnityObjC] dealloc");
  #endif

    self.engine = NULL;
    self.continuousPlayer = NULL;
}

- (void) playContinuousHaptic:(float) intensity :(float)sharpness :(float)duration {
  #if DEBUG
      NSLog(@"[CoreHapticUnityObjC] playContinuousHaptic --> intensity: %f, sharpness: %f, isSupportHaptic: %d, engine: %@, player: %@", intensity, sharpness, [self isSupportHaptic], self.engine, self.continuousPlayer);
  #endif

    if (intensity > 1 || intensity <= 0) return;
    if (sharpness > 1 || sharpness < 0) return;
    if (duration <= 0 || duration > 30) return;

    if ([self isSupportHaptic]) {

        if (self.engine == NULL) {
            [self createEngine];
        }
        [self startEngine];

        [self createContinuousPlayer:intensity :sharpness :duration];

        NSError* error = nil;
        [_continuousPlayer startAtTime:0 error:&error];

        if (error != nil) {
            NSLog(@"[CoreHapticUnityObjC] Engine play continuous error --> %@", error);
        } else {

        }
    }
}

- (void) playTransientHaptic:(float) intensity :(float)sharpness {
  #if DEBUG
      NSLog(@"[CoreHapticUnityObjC] playTransientHaptic --> intensity: %f, sharpness: %f, isSupportHaptic: %d, engine: %@", intensity, sharpness, [self isSupportHaptic], self.engine);
  #endif

    if (intensity > 1 || intensity <= 0) return;
    if (sharpness > 1 || sharpness < 0) return;

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
                NSLog(@"[CoreHapticUnityObjC] Create transient player error --> %@", error);
            }
        } else {
            NSLog(@"[CoreHapticUnityObjC] Create transient pattern error --> %@", error);
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
                NSLog(@"[CoreHapticUnityObjC] Create dictionary player error --> %@", error);
            }
        } else {
            NSLog(@"[CoreHapticUnityObjC] Create dictionary pattern error --> %@", error);
        }
    }
}

- (void) playWithDictionaryFromJsonPattern: (NSString*) jsonDict {
    if (jsonDict != nil) {
        #if DEBUG
            NSLog(@"[CoreHapticUnityObjC] playWithDictionaryFromJsonPattern --> json: %@", jsonDict);
        #endif
        
        NSError* error = nil;
        NSData* data = [jsonDict dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

        if (error == nil) {
            [self playWithDictionaryPattern:dict];
        } else {
            NSLog(@"[CoreHapticUnityObjC] Create dictionary from json error --> %@", error);
        }
    } else {
        NSLog(@"[CoreHapticUnityObjC] Json dictionary string is nil");
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
        NSLog(@"[CoreHapticUnityObjC] url string is nil");
    }
}

- (void) playWithAHAPFileFromURL: (NSURL*) url {
    NSError * error = nil;
    [_engine playPatternFromURL:url error:&error];

    if (error != nil) {
        NSLog(@"[CoreHapticUnityObjC] Engine play from AHAP file error --> %@", error);
    }
}

- (void) updateContinuousHaptic:(float) intensity :(float)sharpness {
  #if DEBUG
      NSLog(@"[CoreHapticUnityObjC] updateContinuousHaptic --> intensity: %f, sharpness: %f, isSupportHaptic: %d, engine: %@, player: %@", intensity, sharpness, [self isSupportHaptic], self.engine, self.continuousPlayer);
  #endif

    if (intensity > 1 || intensity <= 0) return;
    if (sharpness > 1 || sharpness < 0) return;

    if ([self isSupportHaptic] && _engine != NULL && _continuousPlayer != NULL) {

        CHHapticDynamicParameter* intensityParam = [[CHHapticDynamicParameter alloc] initWithParameterID:CHHapticDynamicParameterIDHapticIntensityControl value:intensity relativeTime:0];
        CHHapticDynamicParameter* sharpnessParam = [[CHHapticDynamicParameter alloc] initWithParameterID:CHHapticDynamicParameterIDHapticSharpnessControl value:sharpness relativeTime:0];

        NSError* error = nil;
        [_continuousPlayer sendParameters:@[intensityParam, sharpnessParam] atTime:0 error:&error];

        if (error != nil) {
            NSLog(@"[CoreHapticUnityObjC] Update contuous parameters error --> %@", error);
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
    [self createContinuousPlayer: 1.0 :0.5 :30];
}

- (void) createContinuousPlayer:(float) intens :(float)sharp :(float) duration {
    if ([self isSupportHaptic]) {
        CHHapticEventParameter* intensity = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:intens];
        CHHapticEventParameter* sharpness = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:sharp];

        CHHapticEvent* event = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticContinuous parameters:@[intensity, sharpness] relativeTime:0 duration:duration];

        NSError* error = nil;
        CHHapticPattern* pattern = [[CHHapticPattern alloc] initWithEvents:@[event] parameters:@[] error:&error];

        if (error == nil) {
            _continuousPlayer = [_engine createAdvancedPlayerWithPattern:pattern error:&error];
        } else {
            NSLog(@"[CoreHapticUnityObjC] Create contuous player error --> %@", error);
        }
    }
}

- (void) createEngine {
    if ([self isSupportHaptic]) {
        NSError* error = nil;
        _engine = [[CHHapticEngine alloc] initAndReturnError:&error];

        if (error == nil) {

            _engine.playsHapticsOnly = true;
            __weak CoreHapticUnityObjC *weakSelf = self;

            _engine.stoppedHandler = ^(CHHapticEngineStoppedReason reason) {
                NSLog(@"[CoreHapticUnityObjC] The engine stopped for reason: %ld", (long)reason);
                switch (reason) {
                    case CHHapticEngineStoppedReasonAudioSessionInterrupt:
                        NSLog(@"[CoreHapticUnityObjC] Audio session interrupt");
                        break;
                    case CHHapticEngineStoppedReasonApplicationSuspended:
                        NSLog(@"[CoreHapticUnityObjC] Application suspended");
                        break;
                    case CHHapticEngineStoppedReasonIdleTimeout:
                        NSLog(@"[CoreHapticUnityObjC] Idle timeout");
                        break;
                    case CHHapticEngineStoppedReasonSystemError:
                        NSLog(@"[CoreHapticUnityObjC] System error");
                        break;
                    case CHHapticEngineStoppedReasonNotifyWhenFinished:
                        NSLog(@"[CoreHapticUnityObjC] Playback finished");
                        break;

                    default:
                        NSLog(@"[CoreHapticUnityObjC] Unknown error");
                        break;
                }
                
                weakSelf.isEngineStarted = false;
                
                if (onHapticFinished != NULL) {
                    onHapticFinished((int)reason);
                }
            };

            _engine.resetHandler = ^{
                [weakSelf startEngine];
            };
        } else {
            NSLog(@"[CoreHapticUnityObjC] Engine init error --> %@", error);
        }
    }
}

- (void) startEngine {
    if (!_isEngineStarted) {
        NSError* reseterror = nil;
        [_engine startAndReturnError:&reseterror];

        if (reseterror != nil) {
            NSLog(@"[CoreHapticUnityObjC] Engine reset error --> %@", reseterror);
        } else {
            _isEngineStarted = true;
        }
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
      return [[NSString alloc] initWithUTF8String:string];
  else
      return [NSString stringWithUTF8String: ""];
}

@end


#pragma mark - Bridge

extern "C" {
    void _coreHapticsUnityPlayContinuous(float intensity, float sharpness, int duration) {
        [[CoreHapticUnityObjC shared] playContinuousHaptic:intensity :sharpness :duration];
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

    void _coreHapticsRegisterCallback(hapticCallback callback) {
        [CoreHapticUnityObjC registerCallback:callback];
    }
}
