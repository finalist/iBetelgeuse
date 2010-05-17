//
//  ARDimension.m
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

#import "ARDimension.h"
#import "TCXMLParserDelegate+Protected.h"


@interface ARDimension ()

@property(nonatomic, readwrite, copy) NSArray *features;
@property(nonatomic, readwrite, copy) NSArray *overlays;
@property(nonatomic, readwrite, copy) NSDictionary *locations;
@property(nonatomic, readwrite, copy) NSDictionary *assets;
@property(nonatomic, readwrite) BOOL relativeAltitude;
@property(nonatomic, readwrite, copy) NSString *refreshURL;
@property(nonatomic, readwrite) NSTimeInterval refreshTime;
@property(nonatomic, readwrite) CLLocationDistance refreshDistance;

@end


@interface ARDimensionXMLParserDelegate : TCXMLParserDelegate {
@private
	ARDimension *dimension;
}

@end


@implementation ARDimension

@synthesize features, overlays, locations, assets, relativeAltitude, refreshURL, refreshTime, refreshDistance;

#pragma mark NSObject

- (void)dealloc {
	[features release];
	[overlays release];
	[locations release];
	[assets release];
	[refreshURL release];
	
	[super dealloc];
}

#pragma mark ARDimension

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo {
	ARDimensionXMLParserDelegate *delegate = [[ARDimensionXMLParserDelegate alloc] init];
	[delegate startWithXMLParser:parser element:element attributes:attributes notifyTarget:target selector:selector userInfo:userInfo];
	[delegate release];
}

@end


@implementation ARDimensionXMLParserDelegate

#pragma mark NSObject

- (void)dealloc {
	[dimension release];
	
	[super dealloc];
}

#pragma mark TCXMLParserDelegate

- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes {
	[dimension release];
	dimension = [[ARDimension alloc] init];
}

- (id)parsingDidEndWithElementContent:(NSString *)content {
	return dimension;
}

@end
