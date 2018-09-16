#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    AVSpeechSynthesizer *speechSynthesizer = [[AVSpeechSynthesizer alloc]init];
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterMethodChannel* ttsChanel = [FlutterMethodChannel
                                       methodChannelWithName:@"com.example.otsu/tts"
                                       binaryMessenger:controller];
    
    [ttsChanel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"speak" isEqualToString:call.method])
        {
            if (!speechSynthesizer.isSpeaking)
            {
                NSString *from = call.arguments[@"output"];
                AVSpeechUtterance *speechUtterance = [AVSpeechUtterance speechUtteranceWithString: from];
                
                [speechUtterance setRate: AVSpeechUtteranceMaximumSpeechRate / 3];
                speechUtterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-us"];
                speechUtterance.pitchMultiplier = 1.0f;
                [speechUtterance setVolume:0.9f];
                [speechSynthesizer speakUtterance: speechUtterance];
            }
            
            result(@1);
        }
    }];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
