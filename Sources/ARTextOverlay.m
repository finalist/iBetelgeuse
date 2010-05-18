//
//  ARTextOverlay.m
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

#import "ARTextOverlay.h"
#import "AROverlay+Protected.h"
#import "TCXMLParserDelegate+Protected.h"


@interface ARTextOverlayXMLParserDelegate : AROverlayXMLParserDelegate {
@private
	ARTextOverlay *textOverlay;
	BOOL widthSet;
}

@end


@interface ARTextOverlay ()

@property(nonatomic, readwrite, copy) NSString *text;
@property(nonatomic, readwrite) CGFloat width;

@end


@implementation ARTextOverlay

@synthesize text, width;

#pragma mark NSObject

- (void)dealloc {
	[text release];
	
	[super dealloc];
}

#pragma mark AROverlay

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo {
	ARTextOverlayXMLParserDelegate *delegate = [[ARTextOverlayXMLParserDelegate alloc] init];
	[delegate startWithXMLParser:parser element:element attributes:attributes notifyTarget:target selector:selector userInfo:userInfo];
	[delegate release];
}

@end


@implementation ARTextOverlayXMLParserDelegate

@synthesize overlay = textOverlay;

#pragma mark NSObject

- (void)dealloc {
	[textOverlay release];
	
	[super dealloc];
}

#pragma mark TCXMLParserDelegate

- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes {
	[textOverlay release];
	textOverlay = [[ARTextOverlay alloc] init];
	widthSet = NO;
	
	[super parsingDidStartWithElement:name attributes:attributes];
}

- (void)parsingDidFindSimpleElement:(NSString *)name attributes:(NSDictionary *)attributes content:(NSString *)content {
	if ([name isEqualToString:@"text"]) {
		[textOverlay setText:content];
	}
	else if ([name isEqualToString:@"width"]) {
		double value = [content doubleValue];
		if (value == HUGE_VAL || value == -HUGE_VAL) {
			DebugLog(@"Invalid value for width element: %@", content);
		}
		else {
			[textOverlay setWidth:value];
			widthSet = YES;
		}
	}
	else {
		[super parsingDidFindSimpleElement:name attributes:attributes content:content];
	}
}

- (id)parsingDidEndWithElementContent:(NSString *)content {
	if ([textOverlay text] != nil && widthSet) {
		return [super parsingDidEndWithElementContent:content];
	}
	else {
		return nil;
	}
}

@end
