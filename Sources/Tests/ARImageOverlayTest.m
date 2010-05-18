//
//  ARImageOverlayTest.m
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

#import "ARImageOverlayTest.h"
#import "ARImageOverlay.h"
#import "ARAction.h"


@interface ARImageOverlayTest () <NSXMLParserDelegate>

- (void)assertParseDidFailWithPath:(NSString *)path;

@end


@implementation ARImageOverlayTest

#pragma mark GHTestCase

- (void)setUp {
	[overlay release];
	overlay = nil;
}

- (void)testParseComplete {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARImageOverlayTestComplete.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(overlay, nil);
	GHAssertEqualObjects([overlay identifier], @"anOverlay", nil);
	GHAssertEqualObjects([overlay assetIdentifier], @"anAsset", nil);
	GHAssertEquals([overlay origin], CGPointMake(10, 20), nil);
	GHAssertEquals([overlay anchor], ARAnchorMake(0.5, 0.5), nil);
	GHAssertEquals([[overlay action] type], ARActionTypeRefresh, nil);
	
	[parser release];
}

- (void)testParseBare {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARImageOverlayTestBare.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(overlay, nil);
	GHAssertNil([overlay identifier], nil);
	GHAssertEqualObjects([overlay assetIdentifier], @"anAsset", nil);
	GHAssertEquals([overlay origin], CGPointMake(10, 20), nil);
	GHAssertEquals([overlay anchor], ARAnchorMake(0.5, 1.0), nil);
	GHAssertNil([overlay action], nil);
	
	[parser release];
}

- (void)testParseFail {
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARImageOverlayTestFailAssetIdentifier.xml"];
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARImageOverlayTestFailX.xml"];
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARImageOverlayTestFailY.xml"];
}

#pragma mark ARImageOverlayTest

- (void)assertParseDidFailWithPath:(NSString *)path {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNil(overlay, nil);
	
	[parser release];
}

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"overlayImg"]) {
		[ARImageOverlay startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(didParseOverlay:) userInfo:nil];
	}
}

- (void)didParseOverlay:(ARImageOverlay *)anOverlay {
	[overlay release];
	overlay = [anOverlay retain];
}

@end
