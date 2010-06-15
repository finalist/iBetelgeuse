//
//  ARScannerFlash.m
//  iBetelgeuse
//
//  Copyright 2010 Finalist IT Group. All rights reserved.
//
//  This file is part of iBetelgeuse.
//  
//  iBetelgeuse is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  iBetelgeuse is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with iBetelgeuse.  If not, see <http://www.gnu.org/licenses/>.
//

#import "ARScannerFlash.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>


#define FLASH_DURATION 0.3


static UIWindow *window = nil;
static CAAnimation *animation = nil;
static SystemSoundID beepToneSoundID = 0;


@implementation ARScannerFlash

#pragma mark NSObject

+ (void)initialize {
	// Get notified about memory warnings
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

+ (id)allocWithZone:(NSZone *)aZone {
	// There's no use allocating instances of this class
	return nil;
}

#pragma mark ARScannerFlash

+ (void)flash {
	[self flashWithBeepTone:NO];
}

+ (void)flashWithBeepTone:(BOOL)beep {
	// Configure the window, creating one if necessary
	if (window == nil) {
		window = [[UIWindow alloc] init];
		[window setUserInteractionEnabled:NO];
		[window setWindowLevel:UIWindowLevelStatusBar]; // Display above *everything* else
		[window setBackgroundColor:[UIColor redColor]];
		[window setHidden:NO];
		[[window layer] setOpacity:0.0];
	}
	[window setFrame:[[UIScreen mainScreen] bounds]];
	[window setHidden:NO];
	
	// Configure the animation, creating one if necessary
	if (animation == nil) {
		CABasicAnimation *basicAnimation = [[CABasicAnimation alloc] init];
		[basicAnimation setDelegate:self];
		[basicAnimation setKeyPath:@"opacity"];
		[basicAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
		[basicAnimation setDuration:FLASH_DURATION];
		[basicAnimation setFromValue:[NSNumber numberWithFloat:1.0]];
		animation = basicAnimation;
	}
	[[window layer] addAnimation:animation forKey:nil];
	
	// Configure the beep tone, creating it if necessary
	if (beep) {
		if (beepToneSoundID == 0) {
			CFBundleRef mainBundle = CFBundleGetMainBundle();
			CFURLRef beepToneFileURL = CFBundleCopyResourceURL(mainBundle, CFSTR("Scanner"), CFSTR("wav"), NULL);
			if (AudioServicesCreateSystemSoundID(beepToneFileURL, &beepToneSoundID) != 0) {
				DebugLog(@"Error attempting to create system sound for beep tone");
			}
			CFRelease(beepToneFileURL);
		}
		if (beepToneSoundID != 0) {
			AudioServicesPlaySystemSound(beepToneSoundID);
		}
	}
}

#pragma mark CAAnimationDelegate

+ (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	[window setHidden:YES];
}

#pragma mark UIApplicationNotification

+ (void)applicationDidReceiveMemoryWarning:(NSNotification *)notification {
	if ([window isHidden]) {
		[window release];
		window = nil;
	}
	
	[animation release];
	animation = nil;
	
	AudioServicesDisposeSystemSoundID(beepToneSoundID);
	beepToneSoundID = 0;
}

@end
