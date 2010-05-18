//
//  ARAssetTest.m
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

#import "ARAssetTest.h"
#import "ARAsset.h"


@interface ARAssetTest () <NSXMLParserDelegate>

- (void)assertParseDidFailWithPath:(NSString *)path;

@end


@implementation ARAssetTest

#pragma mark GHTestCase

- (void)setUp {
	[asset release];
	asset = nil;
}

- (void)assertParseDidFailWithPath:(NSString *)path {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNil(asset, nil);
	
	[parser release];
}

- (void)testParseComplete {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARAssetTestComplete.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(asset, nil);
	GHAssertEqualObjects([asset identifier], @"anAsset", nil);
	GHAssertEqualObjects([asset format], @"PNG", nil);
	GHAssertEqualObjects([asset URL], [NSURL URLWithString:@"http://www.example.com/"], nil);
	
	[parser release];
}

- (void)testParseBare {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:TEST_RESOURCES_PATH @"/ARAssetTestBare.xml"]];
	[parser setDelegate:self];
	[parser parse];
	
	GHAssertNotNil(asset, nil);
	GHAssertEqualObjects([asset identifier], @"anAsset", nil);
	GHAssertNil([asset format], nil);
	GHAssertEqualObjects([asset URL], [NSURL URLWithString:@"http://www.example.com/"], nil);
	
	[parser release];
}

- (void)testParseFail {
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARAssetTestFailIdentifier.xml"];
	[self assertParseDidFailWithPath:TEST_RESOURCES_PATH @"/ARAssetTestFailURL.xml"];
}

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"asset"]) {
		[ARAsset startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(didParseAsset:) userInfo:nil];
	}
}

- (void)didParseAsset:(ARAsset *)anAsset {
	[asset release];
	asset = [anAsset retain];
}

@end
