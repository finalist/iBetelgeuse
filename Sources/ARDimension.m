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
#import "ARLocation.h"
#import "ARAsset.h"
#import "ARImageOverlay.h"
#import "ARTextOverlay.h"
#import "ARHTMLOverlay.h"
#import "ARImageFeature.h"
#import "ARTextFeature.h"
#import "TCXMLParserDelegate+Protected.h"
#import "NSObject+ARClassInvariant.h"


#define DEFAULT_RADAR_RADIUS 1000 // meters


const NSTimeInterval ARDimensionRefreshTimeInfinite = 0.0;
const CLLocationDistance ARDimensionRefreshDistanceInfinite = 0.0;


@interface ARDimension ()

@property(nonatomic, readwrite, copy) NSArray *features;
@property(nonatomic, readwrite, copy) NSArray *overlays;
@property(nonatomic, readwrite, copy) NSDictionary *locations;
@property(nonatomic, readwrite, copy) NSDictionary *assets;
@property(nonatomic, readwrite, copy) NSString *name;
@property(nonatomic, readwrite) BOOL relativeAltitude;
@property(nonatomic, readwrite, retain) NSURL *refreshURL;
@property(nonatomic, readwrite) NSTimeInterval refreshTime;
@property(nonatomic, readwrite) CLLocationDistance refreshDistance;
@property(nonatomic, readwrite) CLLocationDistance radarRadius;

@end


typedef enum {
	ARDimensionXMLParserDelegateStateRoot,
	ARDimensionXMLParserDelegateStateRefreshTime,
	ARDimensionXMLParserDelegateStateRefreshDistance,
	ARDimensionXMLParserDelegateStateLocations,
	ARDimensionXMLParserDelegateStateAssets,
	ARDimensionXMLParserDelegateStateFeatures,
	ARDimensionXMLParserDelegateStateOverlays,
} ARDimensionXMLParserDelegateState;


/**
 * Class that can be used as a delegate of an NSXMLParser to parse a dimension.
 */
@interface ARDimensionXMLParserDelegate : TCXMLParserDelegate {
@private
	ARDimension *dimension;
	ARDimensionXMLParserDelegateState state;
	
	NSMutableDictionary *locations;
	NSMutableDictionary *assets;
	NSMutableArray *features;
	NSMutableArray *overlays;
}

/**
 * Callback used when parsing a location.
 *
 * @param location The location that has been parsed, or nil if parsing failed.
 */
- (void)parserDidFindLocation:(ARLocation *)location;

/**
 * Callback used when parsing an asset.
 *
 * @param asset The asset that has been parsed, or nil if parsing failed.
 */
- (void)parserDidFindAsset:(ARAsset *)asset;

/**
 * Callback used when parsing a feature.
 *
 * @param feature The feature that has been parsed, or nil if parsing failed.
 */
- (void)parserDidFindFeature:(ARFeature *)feature;

/**
 * Callback used when parsing an overlay.
 *
 * @param overlay The overlay that has been parsed, or nil if parsing failed.
 */
- (void)parserDidFindOverlay:(AROverlay *)overlay;

@end


@interface ARDimension ()

/**
 * Resolves the concrete location for features that only have a location identifier.
 */
- (void)resolveIdentifiers;

@end


@implementation ARDimension

ARDefineClassInvariant(ARSuperClassInvariant && refreshTime >= 0 && refreshDistance >= 0 && radarRadius > 0);

@synthesize features, overlays, locations, assets, name, relativeAltitude, refreshURL, refreshTime, refreshDistance, radarRadius;

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		radarRadius = DEFAULT_RADAR_RADIUS;
		
		ARAssertClassInvariant();
	}
	return self;
}

- (void)dealloc {
	[features release];
	[overlays release];
	[locations release];
	[assets release];
	[name release];
	[refreshURL release];
	
	[super dealloc];
}

#pragma mark ARDimension

- (void)resolveIdentifiers {
	ARAssertClassInvariant();
	
	for (ARFeature *feature in features) {
		if (![feature location] && [feature locationIdentifier]) {
			[feature setIdentifiedLocation:[locations objectForKey:[feature locationIdentifier]]];
		}
	}
	
	ARAssertClassInvariant();
}

- (void)setRefreshTime:(NSTimeInterval)aTime {
	NSAssert(aTime >= 0, @"Expected zero or positive refresh time.");
	ARAssertClassInvariant();
	
	refreshTime = aTime;
	
	ARAssertClassInvariant();
}

- (void)setRefreshDistance:(CLLocationDistance)aDistance {
	NSAssert(aDistance >= 0, @"Expected zero or positive refresh distance.");
	ARAssertClassInvariant();
	
	refreshDistance = aDistance;
	
	ARAssertClassInvariant();
}

- (void)setRadarRadius:(CLLocationDistance)aRadius {
	NSAssert(aRadius >= 0, @"Expected strictly positive radar radius.");
	ARAssertClassInvariant();
	
	radarRadius = aRadius;
	
	ARAssertClassInvariant();
}

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo {
	// Note: pre-conditions of this method are enforced by the TCXMLParserDelegate method
	
	ARDimensionXMLParserDelegate *delegate = [[ARDimensionXMLParserDelegate alloc] init];
	[delegate startWithXMLParser:parser element:element attributes:attributes notifyTarget:target selector:selector userInfo:userInfo];
	[delegate release];
}

@end


@implementation ARDimensionXMLParserDelegate

#pragma mark NSObject

- (void)dealloc {
	[dimension release];
	
	[locations release];
	[assets release];
	[features release];
	[overlays release];
	
	[super dealloc];
}

#pragma mark TCXMLParserDelegate

- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes {
	[dimension release];
	dimension = [[ARDimension alloc] init];
	state = ARDimensionXMLParserDelegateStateRoot;
	
	[locations release];
	locations = [[NSMutableDictionary alloc] init];
	[assets release];
	assets = [[NSMutableDictionary alloc] init];
	[features release];
	features = [[NSMutableArray alloc] init];
	[overlays release];
	overlays = [[NSMutableArray alloc] init];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	// Indicates whether we handed off parsing this element to another parser
	BOOL didHandOff = NO;
	
	switch (state) {
		case ARDimensionXMLParserDelegateStateRoot:
			if ([elementName isEqualToString:@"refreshTime"]) {
				state = ARDimensionXMLParserDelegateStateRefreshTime;
			}
			else if ([elementName isEqualToString:@"refreshDistance"]) {
				state = ARDimensionXMLParserDelegateStateRefreshDistance;
			}
			else if ([elementName isEqualToString:@"locations"]) {
				state = ARDimensionXMLParserDelegateStateLocations;
			}
			else if ([elementName isEqualToString:@"assets"]) {
				state = ARDimensionXMLParserDelegateStateAssets;
			}
			else if ([elementName isEqualToString:@"features"]) {
				state = ARDimensionXMLParserDelegateStateFeatures;
			}
			else if ([elementName isEqualToString:@"overlays"]) {
				state = ARDimensionXMLParserDelegateStateOverlays;
			}
			break;
			
		case ARDimensionXMLParserDelegateStateLocations:
			if ([elementName isEqualToString:@"location"]) {
				[ARLocation startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(parserDidFindLocation:) userInfo:nil];
				didHandOff = YES;
			}
			break;
			
		case ARDimensionXMLParserDelegateStateAssets:
			if ([elementName isEqualToString:@"asset"]) {
				[ARAsset startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(parserDidFindAsset:) userInfo:nil];
				didHandOff = YES;
			}
			break;
			
		case ARDimensionXMLParserDelegateStateFeatures:
			if ([elementName isEqualToString:@"featureImg"]) {
				[ARImageFeature startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(parserDidFindFeature:) userInfo:nil];
				didHandOff = YES;
			}
			else if ([elementName isEqualToString:@"featureTxt"]) {
				[ARTextFeature startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(parserDidFindFeature:) userInfo:nil];
				didHandOff = YES;
			}
			break;
			
		case ARDimensionXMLParserDelegateStateOverlays:
			if ([elementName isEqualToString:@"overlayImg"]) {
				[ARImageOverlay startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(parserDidFindOverlay:) userInfo:nil];
				didHandOff = YES;
			}
			else if ([elementName isEqualToString:@"overlayTxt"]) {
				[ARTextOverlay startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(parserDidFindOverlay:) userInfo:nil];
				didHandOff = YES;
			}
			else if ([elementName isEqualToString:@"overlayHtml"]) {
				[ARHTMLOverlay startParsingWithXMLParser:parser element:elementName attributes:attributeDict notifyTarget:self selector:@selector(parserDidFindOverlay:) userInfo:nil];
				didHandOff = YES;
			}
			break;
	}
	
	// Only call the super implementation when the element wasn't handed off
	if (!didHandOff) {
		[super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
	}
}

- (void)parsingDidFindSimpleElement:(NSString *)name attributes:(NSDictionary *)attributes content:(NSString *)content {
	switch (state) {
		case ARDimensionXMLParserDelegateStateRoot:
			if ([name isEqualToString:@"name"]) {
				[dimension setName:content];
			}
			else if ([name isEqualToString:@"relativeAltitude"]) {
				if ([content compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
					[dimension setRelativeAltitude:YES];
				}
				else if ([content compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
					[dimension setRelativeAltitude:NO];
				}
				else {
					DebugLog(@"Invalid value for relativeAltitude element: %@", content);
				}
			}
			else if ([name isEqualToString:@"refreshUrl"]) {
				NSURL *url = [NSURL URLWithString:content];
				if (url == nil) {
					DebugLog(@"Invalid URL for refreshUrl: %@", content);
				}
				else {
					[dimension setRefreshURL:url];
				}
			}
			else if ([name isEqualToString:@"radarRange"]) {
				double value = [content doubleValue];
				if (value <= 0 || value == HUGE_VAL) {
					DebugLog(@"Invalid value for radarRange element: %@", content);
				}
				else {
					[dimension setRadarRadius:value];
				}
			}
			break;
			
		case ARDimensionXMLParserDelegateStateRefreshTime:
			if ([name isEqualToString:@"validFor"]) {
				double value = [content doubleValue];
				if (value < 0 || value == HUGE_VAL) {
					DebugLog(@"Invalid value for validFor element: %@", content);
				}
				else {
					[dimension setRefreshTime:value / 1000.0];
				}
			}
			else if ([name isEqualToString:@"waitForAssets"]) {
				DebugLog(@"The option waitForAssets is ignored.");
			}
			break;
			
		case ARDimensionXMLParserDelegateStateRefreshDistance:
			if ([name isEqualToString:@"validWithinRange"]) {
				double value = [content doubleValue];
				if (value < 0 || value == HUGE_VAL) {
					DebugLog(@"Invalid value for validWithinRange element: %@", content);
				}
				else {
					[dimension setRefreshDistance:value];
				}
			}
			break;
	}
}

- (void)parserDidFindLocation:(ARLocation *)location {
	if (location == nil) {
		DebugLog(@"Got invalid location");
	}
	else if ([location identifier] == nil) {
		DebugLog(@"Skipping location without identifier");
	}
	else {
		[locations setObject:location forKey:[location identifier]];
	}
}

- (void)parserDidFindAsset:(ARAsset *)asset {
	if (asset == nil) {
		DebugLog(@"Got invalid asset");
	}
	else if ([asset identifier] == nil) {
		DebugLog(@"Skipping asset without identifier");
	}
	else {
		[assets setObject:asset forKey:[asset identifier]];
	}
}

- (void)parserDidFindFeature:(ARFeature *)feature {
	if (feature == nil) {
		DebugLog(@"Got invalid feature");
	}
	else {
		[features addObject:feature];
	}
}

- (void)parserDidFindOverlay:(AROverlay *)overlay {
	if (overlay == nil) {
		DebugLog(@"Got invalid overlay");
	}
	else {
		[overlays addObject:overlay];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	[super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
	
	switch (state) {
		case ARDimensionXMLParserDelegateStateRefreshTime:
			if ([elementName isEqualToString:@"refreshTime"]) {
				state = ARDimensionXMLParserDelegateStateRoot;
			}
			break;
			
		case ARDimensionXMLParserDelegateStateRefreshDistance:
			if ([elementName isEqualToString:@"refreshDistance"]) {
				state = ARDimensionXMLParserDelegateStateRoot;
			}
			break;
			
		case ARDimensionXMLParserDelegateStateLocations:
			if ([elementName isEqualToString:@"locations"]) {
				state = ARDimensionXMLParserDelegateStateRoot;
			}
			break;
			
		case ARDimensionXMLParserDelegateStateAssets:
			if ([elementName isEqualToString:@"assets"]) {
				state = ARDimensionXMLParserDelegateStateRoot;
			}
			break;
			
		case ARDimensionXMLParserDelegateStateFeatures:
			if ([elementName isEqualToString:@"features"]) {
				state = ARDimensionXMLParserDelegateStateRoot;
			}
			break;
			
		case ARDimensionXMLParserDelegateStateOverlays:
			if ([elementName isEqualToString:@"overlays"]) {
				state = ARDimensionXMLParserDelegateStateRoot;
			}
			break;
	}
}

- (id)parsingDidEndWithElementContent:(NSString *)content {
	[dimension setLocations:locations];
	[dimension setAssets:assets];
	[dimension setFeatures:features];
	[dimension setOverlays:overlays];
	
	[dimension resolveIdentifiers];

	return dimension;
}

@end
