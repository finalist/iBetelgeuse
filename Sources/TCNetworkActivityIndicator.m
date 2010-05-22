//
//  TCNetworkActivityIndicator.h
//
//  Copyright 2009 Dennis Stevense. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "TCNetworkActivityIndicator.h"


@implementation TCNetworkActivityIndicator

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		retainingTokens = [[NSMutableSet alloc] init];
	}
	return self;
}

- (id)retain {
	// Ignore
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;
}

- (id)autorelease {
	// Ignore
	return self;
}

- (void)release {
	// Ignore
}

- (void)dealloc {
	NSAssert(NO, @"Unxpected deallocation of singleton class.");
	
	[super dealloc];
}

#pragma mark NetworkActivityIndicator

+ (TCNetworkActivityIndicator *)sharedIndicator {
	static TCNetworkActivityIndicator *sharedInstance = nil;
	if (sharedInstance == nil) {
		sharedInstance = [[TCNetworkActivityIndicator alloc] init];
	}
	return sharedInstance;
}

- (void)retainWithToken:(id)token {
	NSAssert(token != nil, @"Expected non-nil token.");
	
	[retainingTokens addObject:token];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	DebugLog(@"Updated network activity indicator visibility to %d", [[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]);
}

- (void)releaseWithToken:(id)token {
	NSAssert(token != nil, @"Expected non-nil token.");
	
	[retainingTokens removeObject:token];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:[retainingTokens count] > 0];
	
	DebugLog(@"Updated network activity indicator visibility to %d", [[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]);
}

@end
