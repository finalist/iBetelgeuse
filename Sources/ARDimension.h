//
//  ARDimension.h
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


/**
 * Value used to indicate a dimension does not need to refresh after a specific amount of time.
 */
extern const NSTimeInterval ARDimensionRefreshTimeInfinite;

/**
 * Value used to indicate a dimension does not need to refresh after a specific distance has been traveled.
 */
extern const CLLocationDistance ARDimensionRefreshDistanceInfinite;


/**
 * Represents a Gamaray dimension.
 */
@interface ARDimension : NSObject {
@private
	NSArray *features;
	NSArray *overlays;
	NSDictionary *locations;
	NSDictionary *assets;
	BOOL relativeAltitude;
	NSURL *refreshURL;
	NSTimeInterval refreshTime;
	CLLocationDistance refreshDistance;
}

/**
 * Starts parsing a dimension using the given XML parser and start element. Notifies the given target after the end element has been parsed, passing the result as the first argument which is either an instance of ARDimension or nil when parsing has failed.
 *
 * @param parser Must be non-nil.
 * @param element The name of the start element. Must be non-nil.
 * @param attributes The attributes of the start element.
 * @param target The target that will be notified when parsing is done. Optional.
 * @param selector The selector used when notifying the target. Required if a target was given.
 * @param userInfo Information that is passed as the second argument to the target. Optional.
 */
+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo;

/**
 * Features that are present in the dimension.
 */
@property(nonatomic, readonly, copy) NSArray *features;

/**
 * Overlays that are present in the dimension.
 */
@property(nonatomic, readonly, copy) NSArray *overlays;

/**
 * Locations that are used in the dimension, keyed by identifier.
 */
@property(nonatomic, readonly, copy) NSDictionary *locations;

/**
 * Assets that are used in the dimension, keyed by identifier.
 */
@property(nonatomic, readonly, copy) NSDictionary *assets;

/**
 * Indicates whether altitudes in this dimension are relative to the device's altitude.
 */
@property(nonatomic, readonly) BOOL relativeAltitude;

/**
 * URL used when this dimension needs to be refreshed.
 */
@property(nonatomic, readonly, retain) NSURL *refreshURL;

/**
 * Amount of time after which this dimension becomes invalid and should be refreshed.
 */
@property(nonatomic, readonly) NSTimeInterval refreshTime;

/**
 * Distance the device moved after which this dimension becomes invalid and should be refreshed.
 */
@property(nonatomic, readonly) CLLocationDistance refreshDistance;

@end
