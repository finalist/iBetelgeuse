//
//  ARHTMLOverlay.m
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

#import "ARHTMLOverlay.h"
#import "AROverlay+Protected.h"
#import "TCXMLParserDelegate+Protected.h"
/**
 * Class that can be used as a delegate of an NSXMLParser to parse a html overlay.
 */
@interface ARHTMLOverlayXMLParserDelegate : AROverlayXMLParserDelegate {
@private
	ARHTMLOverlay *htmlOverlay;
}

@end

@interface ARHTMLOverlay ()

@property(nonatomic, readwrite, copy) NSString *url;
@property(nonatomic, readwrite) CGFloat width;
@property(nonatomic, readwrite) CGFloat height;

@end

@implementation ARHTMLOverlay

@synthesize url, width, height;

#pragma mark NSObject
- (void)dealloc {
	[url release];
	
	[super dealloc];
}

#pragma mark AROverlay

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo {
	// Note: pre-conditions of this method are enforced by the TCXMLParserDelegate method
	
	ARHTMLOverlayXMLParserDelegate *delegate = [[ARHTMLOverlayXMLParserDelegate alloc] init];
	[delegate startWithXMLParser:parser element:element attributes:attributes notifyTarget:target selector:selector userInfo:userInfo];
	[delegate release];
}

- (void)setWidth:(CGFloat)aWidth {
	NSAssert(aWidth > 0, @"Expected undefined or positive width.");
	width = aWidth;
}


- (void)setHeight:(CGFloat)aHeight {
	NSAssert(aHeight > 0, @"Expected undefined or positive height.");
	height = aHeight;
}

@end

@implementation ARHTMLOverlayXMLParserDelegate

@synthesize overlay = htmlOverlay;

#pragma mark NSObject

- (void)dealloc {
	[htmlOverlay release];
	
	[super dealloc];
}

#pragma mark TCXMLParserDelegate

- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes {
	[htmlOverlay release];
	htmlOverlay = [[ARHTMLOverlay alloc] init];
	
	[super parsingDidStartWithElement:name attributes:attributes];
}

- (void)parsingDidFindSimpleElement:(NSString *)name attributes:(NSDictionary *)attributes content:(NSString *)content {
	if ([name isEqualToString:@"url"]) {
		[htmlOverlay setUrl:content];
	}
	else if ([name isEqualToString:@"width"]) {
		double value = [content doubleValue];
		[htmlOverlay setWidth:value];
	}
	else if ([name isEqualToString:@"height"]) {
		double value = [content doubleValue];
		[htmlOverlay setHeight:value];
	}
	else {
		[super parsingDidFindSimpleElement:name attributes:attributes content:content];
	}
}

- (id)parsingDidEndWithElementContent:(NSString *)content {
	if ([htmlOverlay url] != nil) {
		return [super parsingDidEndWithElementContent:content];
	}
	else {
		return nil;
	}
}

@end
