//
//  ARAppDelegate.m
//  iBetelgeuse

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

#import "ARAppDelegate.h"
#import "ARMainController.h"


@interface ARAppDelegate ()

@property(nonatomic, readonly) UIWindow *window;
@property(nonatomic, readonly) UIViewController *viewController;

@end


@implementation ARAppDelegate

#pragma mark NSObject

- (void)dealloc {
	[window release];
	[viewController release];
	
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
		[window addSubview:[[self viewController] view]];
	}
	return window;
}

- (UIViewController *)viewController {
	if (viewController == nil) {
		ARMainController *controller = [[ARMainController alloc] init];
		viewController = controller;
	}
	return viewController;
}

@end
