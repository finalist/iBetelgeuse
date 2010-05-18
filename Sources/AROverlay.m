//
//  AROverlay.m
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

#import "AROverlay+Protected.h"
#import "ARAction.h"
#import "TCXMLParserDelegate+Protected.h"


@interface AROverlay ()

@property(nonatomic, readwrite, copy) NSString *identifier;
@property(nonatomic, readwrite) CGPoint origin;
@property(nonatomic, readwrite) CGPoint anchor;
@property(nonatomic, readwrite, retain) ARAction *action;

@end


@implementation AROverlay

@synthesize identifier, origin, anchor, action;

#pragma mark NSObject

- (id)init {
	NSAssert([self class] != [AROverlay class], @"Unexpected initialization of abstract class.");
	
	if (self = [super init]) {
		// Set default anchor to bottom center
		anchor.x = 0.5;
		anchor.y = 1.0;
	}
	return self;
}

- (void)dealloc {
	[identifier release];
	[action release];
	
	[super dealloc];
}

#pragma mark AROverlay

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo {
	NSAssert(NO, @"Expected implementation in subclass of this abstract class.");
}

@end


@implementation AROverlayXMLParserDelegate

@dynamic overlay;

#pragma mark TCXMLParserDelegate

- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes {
	xSet = NO;
	ySet = NO;
	
	[[self overlay] setIdentifier:[attributes objectForKey:@"id"]];
}

- (void)parsingDidFindSimpleElement:(NSString *)name attributes:(NSDictionary *)attributes content:(NSString *)content {
	if ([name isEqualToString:@"x"]) {
		double value = [content doubleValue];
		if (value == HUGE_VAL || value == -HUGE_VAL) {
			DebugLog(@"Invalid value for x element: %@", content);
		}
		else {
			CGPoint origin = [[self overlay] origin];
			origin.x = [content doubleValue];
			[[self overlay] setOrigin:origin];
			
			xSet = YES;
		}
	}
	else if ([name isEqualToString:@"y"]) {
		double value = [content doubleValue];
		if (value == HUGE_VAL || value == -HUGE_VAL) {
			DebugLog(@"Invalid value for y element: %@", content);
		}
		else {
			CGPoint origin = [[self overlay] origin];
			origin.y = [content doubleValue];
			[[self overlay] setOrigin:origin];
			
			ySet = YES;
		}
	}
	else if ([name isEqualToString:@"anchor"]) {
		BOOL anchorValid;
		ARAnchor anchor = ARAnchorMakeWithXMLString(content, &anchorValid);
		if (!anchorValid) {
			DebugLog(@"Invalid value for anchor element: %@", content);
		}
		else {
			[[self overlay] setAnchor:anchor];
		}
	}
	else if ([name isEqualToString:@"onPress"]) {
		ARAction *action = [[ARAction alloc] initWithString:content];
		[[self overlay] setAction:action];
		[action release];
	}
}

- (id)parsingDidEndWithElementContent:(NSString *)content {
	if (xSet && ySet) {
		return [self overlay];
	}
	else {
		return nil;
	}
}

@end
