//
//  ARAsset.m
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

#import "ARAsset.h"
#import "TCXMLParserDelegate+Protected.h"


@interface ARAsset ()

@property(nonatomic, readwrite, copy) NSString *identifier;
@property(nonatomic, readwrite, copy) NSString *format;
@property(nonatomic, readwrite, copy) NSURL *URL;

@end


@interface ARAssetXMLParserDelegate : TCXMLParserDelegate {
@private
	ARAsset *asset;
}

@end


@implementation ARAsset

@synthesize identifier, format, URL;

#pragma mark NSObject

- (id)initWithURL:(NSURL *)aURL format:(NSString *)aFormat {
	if (self = [super init]) {
		format = [aFormat copy];
		URL = [aURL retain];
	}
	return self;
}

- (void)dealloc {
	[identifier release];
	[format release];
	[URL release];
	
	[super dealloc];
}

#pragma mark ARAsset

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo {
	ARAssetXMLParserDelegate *delegate = [[ARAssetXMLParserDelegate alloc] init];
	[delegate startWithXMLParser:parser element:element attributes:attributes notifyTarget:target selector:selector userInfo:userInfo];
	[delegate release];
}

@end


@implementation ARAssetXMLParserDelegate

#pragma mark NSObject

- (void)dealloc {
	[asset release];
	
	[super dealloc];
}

#pragma mark TCXMLParserDelegate

- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes {
	[asset release];
	asset = [[ARAsset alloc] init];
	
	[asset setIdentifier:[attributes objectForKey:@"id"]];
}

- (void)parsingDidFindSimpleElement:(NSString *)name attributes:(NSDictionary *)attributes content:(NSString *)content {
	if ([name isEqualToString:@"format"]) {
		[asset setFormat:content];
	} else if ([name isEqualToString:@"url"]) {
		NSURL *url = [NSURL URLWithString:content];
		if (!url) {
			DebugLog(@"Invalid value for url element: %@.", content);
		} else {
			[asset setURL:url];
		}
	} else {
		DebugLog(@"Unknown element: %@", name);
	}
}

- (id)parsingDidEndWithElementContent:(NSString *)content {
	if (![asset identifier] || ![asset URL]) {
		return nil;
	} else {
		return asset;
	}
}

@end
