//
//  ARLocation.m
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

#import "ARLocation.h"
#import "ARWGS84.h"
#import "TCXMLParserDelegate+Protected.h"


@interface ARLocation ()

@property(nonatomic, readwrite, copy) NSString *identifier;
@property(nonatomic, readwrite) CLLocationDegrees latitude;
@property(nonatomic, readwrite) CLLocationDegrees longitude;
@property(nonatomic, readwrite) CLLocationDistance altitude;

@end


@interface ARLocationXMLParserDelegate : TCXMLParserDelegate {
@private
	ARLocation *location;
	BOOL latitudeSet;
	BOOL longitudeSet;
	BOOL altitudeSet;
}

@end


@implementation ARLocation

@synthesize identifier, latitude, longitude, altitude;

#pragma mark NSObject

- (id)initWithLatitude:(CLLocationDegrees)aLatitude longitude:(CLLocationDegrees)aLongitude altitude:(CLLocationDistance)anAltitude {
	if (self = [super init]) {
		latitude = aLatitude;
		longitude = aLongitude;
		altitude = anAltitude;
	}
	return self;
}

- (id)initWithCLLocation:(CLLocation *)location {
	NSAssert(location != nil, @"Expected non-nil location.");
	
	if (self = [super init]) {
		latitude = [location coordinate].latitude;
		longitude = [location coordinate].longitude;
		altitude = [location altitude];
	}
	return self;
}

- (void)dealloc {
	[identifier release];
	
	[super dealloc];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[ARLocation class]]) {
		ARLocation *location = (ARLocation *)object;
		return (location->identifier == self->identifier || [location->identifier isEqual:self->identifier]) &&
			location->latitude == self->latitude &&
			location->longitude == self->longitude &&
			location->altitude == self->altitude;
	}
	else {
		return NO;
	}
}

- (NSUInteger)hash {
	return latitude * 100.0 + longitude * 10000000.0;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	ARLocation *location = [ARLocation allocWithZone:zone];
	location->identifier = [self->identifier copyWithZone:zone];
	location->latitude = self->latitude;
	location->longitude = self->longitude;
	location->altitude = self->altitude;
	return location;
}

#pragma mark ARLocation

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo {
	ARLocationXMLParserDelegate *delegate = [[ARLocationXMLParserDelegate alloc] init];
	[delegate startWithXMLParser:parser element:element attributes:attributes notifyTarget:target selector:selector userInfo:userInfo];
	[delegate release];
}

- (ARPoint3D)positionInEcefCoordinates {
	return ARWGS84GetECEF(latitude, longitude, altitude);
}

@end


@implementation ARLocationXMLParserDelegate

#pragma mark NSObject

- (void)dealloc {
	[location release];
	
	[super dealloc];
}

#pragma mark TCXMLParserDelegate

- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes {
	[location release];
	location = [[ARLocation alloc] init];
	
	[location setIdentifier:[attributes objectForKey:@"id"]];
	
	latitudeSet = NO;
	longitudeSet = NO;
	altitudeSet = NO;
}

- (void)parsingDidFindSimpleElement:(NSString *)name attributes:(NSDictionary *)attributes content:(NSString *)content {
	if ([name isEqualToString:@"lat"]) {
		double value = [content doubleValue];
		if (value < -90. || value > 90.) {
			DebugLog(@"Invalid value for latitude element: %@.", content);
		} else {
			[location setLatitude:value];
			latitudeSet = YES;
		}
	} else if ([name isEqualToString:@"lon"]) {
		double value = [content doubleValue];
		if (value < -180. || value > 180.) {
			DebugLog(@"Invalid value for longitude element: %@.", content);
		} else {
			[location setLongitude:value];
			longitudeSet = YES;
		}
	} else if ([name isEqualToString:@"alt"]) {
		double value = [content doubleValue];
		if (value == -HUGE_VAL || value == HUGE_VAL) {
			DebugLog(@"Invalid value for altitude element: %@.", content);
		} else {
			[location setAltitude:value];
			altitudeSet = YES;
		}
	} else {
		DebugLog(@"Unknown element: %@", name);
	}
}

- (id)parsingDidEndWithElementContent:(NSString *)content {
	if (!latitudeSet || !longitudeSet || !altitudeSet) {
		return nil;
	} else {
		return location;
	}
}

@end
