//
//  ARAppDelegate.m
//  iBetelgeuse
//
//  Created by Dennis Stevense on 10/05/10.
//  Copyright Dennis Stevense 2010. All rights reserved.
//

#import "ARAppDelegate.h"


@interface ARAppDelegate ()

@property(nonatomic, readonly) UIWindow *window;

@end


@implementation ARAppDelegate

#pragma mark NSObject

- (void)dealloc {
	[window release];
	
	[super dealloc];
}

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [[self window] makeKeyAndVisible];
	return YES;
}

#pragma mark ARAppDelegate

- (UIWindow *)window {
	if (window == nil) {
		window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	}
	return window;
}

@end
