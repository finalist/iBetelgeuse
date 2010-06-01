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

- (void)testInitWithLatitude {
	// Test postconditions
	ARLocation *l = [[ARLocation alloc] initWithLatitude:10.0 longitude:20.0 altitude:30.0];
	GHAssertEquals([l latitude], (CLLocationDegrees)10.0, nil);
	GHAssertEquals([l longitude], (CLLocationDegrees)20.0, nil);
	GHAssertEquals([l altitude], (CLLocationDistance)30.0, nil);
	[l release];
}

- (void)testInitWithCLLocation {
	// Test preconditions
	GHAssertThrows([[[ARLocation alloc] initWithCLLocation:nil] autorelease], nil);

	// Create a CLLocation
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = 10.0;
	coordinate.longitude = 20.0;
	CLLocation *cl = [[CLLocation alloc] initWithCoordinate:coordinate altitude:30.0 horizontalAccuracy:0.0 verticalAccuracy:0.0 timestamp:nil];
	
	// Test postconditions
	ARLocation *l = [[ARLocation alloc] initWithCLLocation:cl];
	GHAssertEquals([l latitude], coordinate.latitude, nil);
	GHAssertEquals([l longitude], coordinate.longitude, nil);
	GHAssertEquals([l altitude], [cl altitude], nil);
	[l release];
	
	[cl release];
}

- (void)testIdentity {
	ARLocation *l = [[ARLocation alloc] initWithLatitude:10.0 longitude:20.0 altitude:30.0];
	
	// Test equality with same parameters
	ARLocation *m = [[ARLocation alloc] initWithLatitude:10.0 longitude:20.0 altitude:30.0];
	GHAssertTrue([l isEqual:m], nil);
	GHAssertTrue([m isEqual:l], nil);
	GHAssertTrue([l hash] == [m hash], nil);
	[m release];
	
	// Test equality with different latitude
	m = [[ARLocation alloc] initWithLatitude:0.0 longitude:20.0 altitude:30.0];
	GHAssertFalse([l isEqual:m], nil);
	GHAssertFalse([m isEqual:l], nil);
	[m release];
	
	// Test equality with different longitude
	m = [[ARLocation alloc] initWithLatitude:10.0 longitude:0.0 altitude:30.0];
	GHAssertFalse([l isEqual:m], nil);
	GHAssertFalse([m isEqual:l], nil);
	[m release];
	
	// Test equality with different altitude
	m = [[ARLocation alloc] initWithLatitude:10.0 longitude:20.0 altitude:0.0];
	GHAssertFalse([l isEqual:m], nil);
	GHAssertFalse([m isEqual:l], nil);
	[m release];
	
	// Test equality with nil
	GHAssertFalse([l isEqual:nil], nil);
	
	// Test equality with random object
	GHAssertFalse([l isEqual:@"hoi"], nil);
	
	[l release];
}

- (void)testCopying {
	// Test postconditions
	ARLocation *original = [[ARLocation alloc] initWithLatitude:10.0 longitude:20.0 altitude:30.0];
	ARLocation *copy = [original copy];
	GHAssertTrue(original != copy && [original isEqual:copy], nil);
	GHAssertEquals([copy retainCount], (NSUInteger)1, nil);
	[copy release];
	[original release];
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

- (void)testParseBare {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARLocationTestBare.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(location, nil);
	GHAssertNil([location identifier], nil);
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

- (void)testPositionInEcefCoordinates {
	ARLocation *l = [[ARLocation alloc] initWithLatitude:52.469397 longitude:5.509644 altitude:10.0];
	ARPoint3D ecef = [l locationInECEFSpace];
	GHAssertEqualsWithAccuracy(ecef.x, 3875688., 0.5, nil);
	GHAssertEqualsWithAccuracy(ecef.y, 373845., 0.5, nil);
	GHAssertEqualsWithAccuracy(ecef.z, 5034799., 0.5, nil);
	[l release];
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
