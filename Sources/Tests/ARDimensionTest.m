//
//  ARDimensionTest.m
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

#import "ARDimensionTest.h"
#import "ARDimension.h"
#import "ARFeature.h"
#import "AROverlay.h"
#import "ARLocation.h"
#import "ARAsset.h"


@interface ARDimensionTest () <NSXMLParserDelegate>

@end


@implementation ARDimensionTest

#pragma mark GHTestCase

- (void)setUp {
	[dimension release];
	dimension = nil;
}

- (void)testParseComplete {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARDimensionTestComplete.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(dimension, nil);
	GHAssertEquals([[dimension features] count], (NSUInteger)2, nil);
	GHAssertTrue([[[dimension features] objectAtIndex:0] isKindOfClass:[ARFeature class]], nil);
	GHAssertEquals([[dimension overlays] count], (NSUInteger)2, nil);
	GHAssertTrue([[[dimension overlays] objectAtIndex:0] isKindOfClass:[AROverlay class]], nil);
	GHAssertEquals([[dimension locations] count], (NSUInteger)2, nil);
	GHAssertTrue([[[[dimension locations] objectEnumerator] nextObject] isKindOfClass:[ARLocation class]], nil);
	GHAssertEquals([[dimension assets] count], (NSUInteger)2, nil);
	GHAssertTrue([[[[dimension assets] objectEnumerator] nextObject] isKindOfClass:[ARAsset class]], nil);
	GHAssertTrue([dimension relativeAltitude], nil);
	GHAssertEqualObjects([dimension refreshURL], [NSURL URLWithString:@"http://www.example.org/"], nil);
	GHAssertEquals([dimension refreshTime], (NSTimeInterval)1.0, nil);
	GHAssertEquals([dimension refreshDistance], (CLLocationDistance)1000.0, nil);
	
	[parser release];
}

- (void)testParseBare {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARDimensionTestBare.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(dimension, nil);
	GHAssertEquals([[dimension features] count], (NSUInteger)0, nil);
	GHAssertEquals([[dimension overlays] count], (NSUInteger)0, nil);
	GHAssertEquals([[dimension locations] count], (NSUInteger)0, nil);
	GHAssertEquals([[dimension assets] count], (NSUInteger)0, nil);
	GHAssertFalse([dimension relativeAltitude], nil);
	GHAssertNil([dimension refreshURL], nil);
	GHAssertEquals([dimension refreshTime], (NSTimeInterval)0, nil);
	GHAssertEquals([dimension refreshDistance], (CLLocationDistance)0, nil);
	
	[parser release];
}

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"dimension"]) {
		[ARDimension startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(didParseDimension:) userInfo:nil];
	}
}

- (void)didParseDimension:(ARDimension *)aDimension {
	[dimension release];
	dimension = [aDimension retain];
}

@end
