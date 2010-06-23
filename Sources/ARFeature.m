//
//  ARFeature.m
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

#import "ARFeature+Protected.h"
#import "ARAction.h"
#import "ARLocation.h"
#import "TCXMLParserDelegate+Protected.h"


@interface ARFeature ()

@property(nonatomic, readwrite, copy) NSString *identifier;
@property(nonatomic, readwrite, copy) NSString *locationIdentifier;
@property(nonatomic, readwrite, retain) ARLocation *location;
@property(nonatomic, readwrite) CGPoint anchor;
@property(nonatomic, readwrite, retain) ARAction *action;
@property(nonatomic, readwrite) ARPoint3D offset;
@property(nonatomic, readwrite) BOOL showInRadar;

@end


@implementation ARFeature

@synthesize identifier, locationIdentifier, location, anchor, action, offset, showInRadar;

#pragma mark NSObject

- (id)init {
	NSAssert([self class] != [ARFeature class], @"Unexpected initialization of abstract class.");
	
	if (self = [super init]) {
		// Set default anchor to bottom center
		anchor.x = 0.5;
		anchor.y = 1.0;
		
		// Default to true
		showInRadar = YES;
	}
	return self;
}

- (void)dealloc {
	[identifier release];
	[locationIdentifier release];
	[location release];
	[action release];
	
	[super dealloc];
}

#pragma mark ARFeature

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo {
	NSAssert(NO, @"Expected implementation in subclass of this abstract class.");
}

- (void)setIdentifiedLocation:(ARLocation *)aLocation {
	NSAssert([[aLocation identifier] isEqualToString:locationIdentifier], @"Expected given location's identifier to the location identifier.");
	
	if (aLocation != location) {
		[location release];
		location = [aLocation retain];
	}
}

@end


@implementation ARFeatureXMLParserDelegate

@dynamic feature;

#pragma mark TCXMLParserDelegate

- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes {
	[[self feature] setIdentifier:[attributes objectForKey:@"id"]];
}

- (void)parsingDidFindSimpleElement:(NSString *)name attributes:(NSDictionary *)attributes content:(NSString *)content {
	if ([name isEqualToString:@"locationId"]) {
		[[self feature] setLocationIdentifier:content];
	}
	else if ([name isEqualToString:@"anchor"]) {
		BOOL anchorValid;
		ARAnchor anchor = ARAnchorMakeWithXMLString(content, &anchorValid);
		if (!anchorValid) {
			DebugLog(@"Invalid value for %@ element: %@", name, content);
		}
		else {
			[[self feature] setAnchor:anchor];
		}
	}
	else if ([name isEqualToString:@"onPress"]) {
		ARAction *action = [[ARAction alloc] initWithString:content];
		[[self feature] setAction:action];
		[action release];
	}
	else if ([name isEqualToString:@"xLoc"]) {
		double value = [content doubleValue];
		if (value == HUGE_VAL || value == -HUGE_VAL) {
			DebugLog(@"Invalid value for %@ element: %@", name, content);
		}
		else {
			ARPoint3D offset = [[self feature] offset];
			offset.x = value;
			[[self feature] setOffset:offset];
		}
	}
	else if ([name isEqualToString:@"yLoc"]) {
		double value = [content doubleValue];
		if (value == HUGE_VAL || value == -HUGE_VAL) {
			DebugLog(@"Invalid value for %@ element: %@", name, content);
		}
		else {
			ARPoint3D offset = [[self feature] offset];
			offset.y = value;
			[[self feature] setOffset:offset];
		}
	}
	else if ([name isEqualToString:@"zLoc"]) {
		double value = [content doubleValue];
		if (value == HUGE_VAL || value == -HUGE_VAL) {
			DebugLog(@"Invalid value for %@ element: %@", name, content);
		}
		else {
			ARPoint3D offset = [[self feature] offset];
			offset.z = value;
			[[self feature] setOffset:offset];
		}
	}
	else if ([name isEqualToString:@"showInRadar"]) {
		if ([content compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			[[self feature] setShowInRadar:YES];
		}
		else if ([content compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
			[[self feature] setShowInRadar:NO];
		}
		else {
			DebugLog(@"Invalid value for %@ element: %@", name, content);
		}
	}
}

- (id)parsingDidEndWithElementContent:(NSString *)content {
	if ([[self feature] location] || [[self feature] locationIdentifier]) {
		return [self feature];
	}
	else {
		return nil;
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"location"]) {
		[ARLocation startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(didParseLocation:) userInfo:nil];
	} else {
		[super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
	}
}

- (void)didParseLocation:(ARLocation *)aLocation {
	[[self feature] setLocation:aLocation];
}

@end
