//
//  ARAppDelegate.m
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

#import "ARAppDelegate.h"
#import "ARMainController.h"


@interface ARAppDelegate ()

@property(nonatomic, retain) NSURL *initialURL;

@property(nonatomic, readonly) UIWindow *window;
@property(nonatomic, readonly) UIViewController *viewController;

@end


@implementation ARAppDelegate

@synthesize initialURL;

#pragma mark NSObject

- (void)dealloc {
	[initialURL release];
	
	[window release];
	[viewController release];
	
	[super dealloc];
}

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BOOL didHandleURL = YES;
	
	// Check if we were launched with a URL
	NSURL *url;
	if (url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
		// Check if it is a URL that we recognize
		if ([[url scheme] isEqualToString:@"gamaray"] && [url host]) {
			// Change the scheme of the URL to http
			NSString *urlString = [url absoluteString];
			NSRange urlSchemeRange = [urlString rangeOfString:[url scheme] options:NSAnchoredSearch];
			NSString *httpURLString = [urlString stringByReplacingCharactersInRange:urlSchemeRange withString:@"http"];
			[self setInitialURL:[NSURL URLWithString:httpURLString]];
		}
		else {
			didHandleURL = NO;
		}
	}
	
	// Show the main window
    [[self window] makeKeyAndVisible];
	
	return didHandleURL;
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
		ARMainController *controller = [[ARMainController alloc] initWithURL:[self initialURL]];
		viewController = controller;
	}
	return viewController;
}

@end
