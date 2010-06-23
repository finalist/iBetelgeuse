//
//  ARImageFeature.m
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

#import "ARImageFeature.h"
#import "ARFeature+Protected.h"
#import "TCXMLParserDelegate+Protected.h"
#import "NSObject+ARClassInvariant.h"


/**
 * Class that can be used as a delegate of an NSXMLParser to parse an image feature.
 */
@interface ARImageFeatureXMLParserDelegate : ARFeatureXMLParserDelegate {
@private
	ARImageFeature *imageFeature;
}

@end


@interface ARImageFeature ()

@property(nonatomic, readwrite, copy) NSString *assetIdentifier;

@end


@implementation ARImageFeature

ARDefineClassInvariant(ARSuperClassInvariant && assetIdentifier != nil);

@synthesize assetIdentifier;

#pragma mark NSObject

- (void)dealloc {
	[assetIdentifier release];
	
	[super dealloc];
}

#pragma mark ARFeature

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo {
	// Note: pre-conditions of this method are enforced by the TCXMLParserDelegate method
	
	ARImageFeatureXMLParserDelegate *delegate = [[ARImageFeatureXMLParserDelegate alloc] init];
	[delegate startWithXMLParser:parser element:element attributes:attributes notifyTarget:target selector:selector userInfo:userInfo];
	[delegate release];
}

- (void)setAssetIdentifier:(NSString *)aIdentifier {
	NSAssert(aIdentifier != nil, @"Expected non-nil identifier.");
	
	[assetIdentifier release];
	assetIdentifier = [aIdentifier copy];
}

@end


@implementation ARImageFeatureXMLParserDelegate

@synthesize feature = imageFeature;

#pragma mark NSObject

- (void)dealloc {
	[imageFeature release];
	
	[super dealloc];
}

#pragma mark TCXMLParserDelegate

- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes {
	[imageFeature release];
	imageFeature = [[ARImageFeature alloc] init];
	
	[super parsingDidStartWithElement:name attributes:attributes];
}

- (void)parsingDidFindSimpleElement:(NSString *)name attributes:(NSDictionary *)attributes content:(NSString *)content {
	if ([name isEqualToString:@"assetId"]) {
		[imageFeature setAssetIdentifier:content];
	}
	else {
		[super parsingDidFindSimpleElement:name attributes:attributes content:content];
	}
}

- (id)parsingDidEndWithElementContent:(NSString *)content {
	if ([imageFeature assetIdentifier] != nil) {
		id result = [super parsingDidEndWithElementContent:content];
		ARAssertClassInvariantOfObject(result);
		return result;		
	}
	else {
		return nil;
	}
}

@end
