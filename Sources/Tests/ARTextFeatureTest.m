//
//  ARTextFeatureTest.m
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

#import "ARTextFeatureTest.h"
#import "ARTextFeature.h"
#import "ARAction.h"
#import "ARLocation.h"


@interface ARTextFeatureTest () <NSXMLParserDelegate>

- (void)assertParseDidFailWithPath:(NSString *)path;

@end


@implementation ARTextFeatureTest

#pragma mark GHTestCase

- (void)setUp {
	[feature release];
	feature = nil;
}

- (void)testParseComplete {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARTextFeatureTestComplete.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(feature, nil);
	GHAssertEqualObjects([feature identifier], @"aFeature", nil);
	GHAssertEqualObjects([feature locationIdentifier], @"aLocation", nil);
	GHAssertTrue([[feature location] isKindOfClass:[ARLocation class]], nil);
	GHAssertEquals([feature anchor], ARAnchorMake(0.5, 0.5), nil);
	GHAssertTrue([[feature action] isKindOfClass:[ARAction class]], nil);
	GHAssertTrue(ARPoint3DEquals([feature offset], ARPoint3DMake(12.34, 23.45, 34.56)), nil);
	GHAssertFalse([feature showInRadar], nil);
	GHAssertEqualObjects([feature text], @"Foo", nil);
	
	[parser release];
}

- (void)testParseBareLocationIdentifier {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARTextFeatureTestBareLocationId.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(feature, nil);
	GHAssertNil([feature identifier], nil);
	GHAssertEqualObjects([feature locationIdentifier], @"aLocation", nil);
	GHAssertNil([feature location], nil);
	GHAssertEquals([feature anchor], ARAnchorMake(0.5, 1.0), nil);
	GHAssertNil([feature action], nil);
	GHAssertTrue(ARPoint3DEquals([feature offset], ARPoint3DMake(0, 0, 0)), nil);
	GHAssertTrue([feature showInRadar], nil);
	GHAssertEqualObjects([feature text], @"Foo", nil);
	
	[parser release];
}

- (void)testParseBareLocation {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARTextFeatureTestBareLocation.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(feature, nil);
	GHAssertNil([feature identifier], nil);
	GHAssertNil([feature locationIdentifier], nil);
	GHAssertTrue([[feature location] isKindOfClass:[ARLocation class]], nil);
	GHAssertEquals([feature anchor], ARAnchorMake(0.5, 1.0), nil);
	GHAssertNil([feature action], nil);
	GHAssertTrue(ARPoint3DEquals([feature offset], ARPoint3DMake(0, 0, 0)), nil);
	GHAssertTrue([feature showInRadar], nil);
	GHAssertEqualObjects([feature text], @"Foo", nil);
	
	[parser release];
}

- (void)testParseFail {
	// TODO: Perform this 'invalid' test isolated for each property
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARTextFeatureTestInvalid.xml"];
	
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARTextFeatureTestFailLocation.xml"];
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARTextFeatureTestFailText.xml"];
}

- (void)testParseOther {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARTextFeatureTestOther.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(feature, nil);
	GHAssertTrue([feature showInRadar], nil);
	
	[parser release];
}

#pragma mark ARTextFeatureTest

- (void)assertParseDidFailWithPath:(NSString *)path {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNil(feature, nil);
	
	[parser release];
}

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"featureTxt"]) {
		[ARTextFeature startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(didParseFeature:) userInfo:nil];
	}
}

- (void)didParseFeature:(ARTextFeature *)aFeature {
	[feature release];
	feature = [aFeature retain];
}

@end
