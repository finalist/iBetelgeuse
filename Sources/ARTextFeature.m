//
//  ARTextFeature.m
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

#import "ARTextFeature.h"
#import "ARFeature+Protected.h"
#import "TCXMLParserDelegate+Protected.h"


@interface ARTextFeatureXMLParserDelegate : ARFeatureXMLParserDelegate {
@private
	ARTextFeature *textFeature;
}

@end


@interface ARTextFeature ()

@property(nonatomic, readwrite, copy) NSString *text;

@end


@implementation ARTextFeature

@synthesize text;

#pragma mark NSObject

- (void)dealloc {
	[text release];
	
	[super dealloc];
}

#pragma mark ARFeature

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo {
	ARTextFeatureXMLParserDelegate *delegate = [[ARTextFeatureXMLParserDelegate alloc] init];
	[delegate startWithXMLParser:parser element:element attributes:attributes notifyTarget:target selector:selector userInfo:userInfo];
	[delegate release];
}

@end


@implementation ARTextFeatureXMLParserDelegate

@synthesize feature = textFeature;

#pragma mark NSObject

- (void)dealloc {
	[textFeature release];
	
	[super dealloc];
}

#pragma mark TCXMLParserDelegate

- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes {
	[textFeature release];
	textFeature = [[ARTextFeature alloc] init];
	
	[super parsingDidStartWithElement:name attributes:attributes];
}

- (void)parsingDidFindSimpleElement:(NSString *)name attributes:(NSDictionary *)attributes content:(NSString *)content {
	if ([name isEqualToString:@"text"]) {
		[textFeature setText:content];
	}
	else {
		[super parsingDidFindSimpleElement:name attributes:attributes content:content];
	}
}

- (id)parsingDidEndWithElementContent:(NSString *)content {
	if ([textFeature text] != nil) {
		return [super parsingDidEndWithElementContent:content];
	}
	else {
		return nil;
	}
}

@end
