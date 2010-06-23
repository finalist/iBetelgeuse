//
//  ARImageOverlay.m
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

#import "ARImageOverlay.h"
#import "AROverlay+Protected.h"
#import "TCXMLParserDelegate+Protected.h"


/**
 * Class that can be used as a delegate of an NSXMLParser to parse an image overlay.
 */
@interface ARImageOverlayXMLParserDelegate : AROverlayXMLParserDelegate {
@private
	ARImageOverlay *imageOverlay;
}

@end


@interface ARImageOverlay ()

@property(nonatomic, readwrite, copy) NSString *assetIdentifier;

@end


@implementation ARImageOverlay

@synthesize assetIdentifier;

#pragma mark NSObject

- (void)dealloc {
	[assetIdentifier release];
	
	[super dealloc];
}

#pragma mark AROverlay

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo {
	// Note: pre-conditions of this method are enforced by the TCXMLParserDelegate method
	
	ARImageOverlayXMLParserDelegate *delegate = [[ARImageOverlayXMLParserDelegate alloc] init];
	[delegate startWithXMLParser:parser element:element attributes:attributes notifyTarget:target selector:selector userInfo:userInfo];
	[delegate release];
}

@end


@implementation ARImageOverlayXMLParserDelegate

@synthesize overlay = imageOverlay;

#pragma mark NSObject

- (void)dealloc {
	[imageOverlay release];
	
	[super dealloc];
}

#pragma mark TCXMLParserDelegate

- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes {
	[imageOverlay release];
	imageOverlay = [[ARImageOverlay alloc] init];
	
	[super parsingDidStartWithElement:name attributes:attributes];
}

- (void)parsingDidFindSimpleElement:(NSString *)name attributes:(NSDictionary *)attributes content:(NSString *)content {
	if ([name isEqualToString:@"assetId"]) {
		[imageOverlay setAssetIdentifier:content];
	}
	else {
		[super parsingDidFindSimpleElement:name attributes:attributes content:content];
	}
}

- (id)parsingDidEndWithElementContent:(NSString *)content {
	if ([imageOverlay assetIdentifier] != nil) {
		return [super parsingDidEndWithElementContent:content];
	}
	else {
		return nil;
	}
}

@end
