//
//  ARAction.m
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

#import "ARAction.h"


@implementation ARAction

@synthesize type, URL;

#pragma mark NSObject

- (void)dealloc {
	[URL release];
	
	[super dealloc];
}

#pragma mark ARAction

- (ARAction *)initWithString:(NSString *)string {
	NSAssert(string != nil, @"Expected non-nil string.");
	
	if (!(self = [super init])) {
		return nil;
	}
	
	NSRange separatorRange = [string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
	NSString *typeString;
	NSString *URLString;
	if (separatorRange.location != NSNotFound) {
		typeString = [string substringToIndex:separatorRange.location];
		URLString = [[string substringFromIndex:separatorRange.location + separatorRange.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	} else {
		typeString = string;
		URLString = nil;
	}
	
	if ([typeString isEqualToString:@"refresh"]) {
		type = ARActionTypeRefresh;
	} else if ([typeString isEqualToString:@"webpage"]) {
		type = ARActionTypeURL;
	} else if ([typeString isEqualToString:@"dimension"]) {
		type = ARActionTypeDimension;
	} else {
		DebugLog(@"Invalid action string: %@", string);
		[self release];
		return nil;
	}
	
	if (URLString) {
		URL = [[NSURL alloc] initWithString:URLString];
	}
	
	if ((type == ARActionTypeURL || type == ARActionTypeDimension) && !URL)
	{
		DebugLog(@"Missing URL: %@", string);
		[self release];
		return nil;
	}
	
	return self;
}

@end
