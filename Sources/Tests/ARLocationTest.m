//
//  ARLocationTest.m
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

#import "ARLocationTest.h"
#import "ARLocation.h"


@interface ARLocationTest () <NSXMLParserDelegate>

- (void)assertParseDidFailWithPath:(NSString *)path;

@end


@implementation ARLocationTest

#pragma mark GHTestCase

- (void)setUp {
	[location release];
	location = nil;
}

- (void)assertParseDidFailWithPath:(NSString *)path {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNil(location, nil);
	
	[parser release];
}

- (void)testParseComplete {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARLocationTestComplete.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(location, nil);
	GHAssertEqualObjects([location identifier], @"aLocation", nil);
	GHAssertEquals([location latitude], (CLLocationDegrees)12.34, nil);
	GHAssertEquals([location longitude], (CLLocationDegrees)23.45, nil);
	GHAssertEquals([location altitude], (CLLocationDistance)34.56, nil);
	
	[parser release];
}

- (void)testParseFail {
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARLocationTestFailIdentifier.xml"];
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARLocationTestFailLatitude.xml"];
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARLocationTestFailLongitude.xml"];
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARLocationTestFailAltitude.xml"];
}

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"location"]) {
		[ARLocation startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(didParseLocation:) userInfo:nil];
	}
}

- (void)didParseLocation:(ARLocation *)aLocation {
	[location release];
	location = [aLocation retain];
}

@end
