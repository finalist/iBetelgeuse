//
//  ARFeature.h
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
#import "ARAnchor.h"
#import "ARPoint3D.h"


@class ARAction;
@class ARLocation;


/**
 * Abstract class that represents a feature in a Gamaray dimension.
 */
@interface ARFeature : NSObject {
@private
	NSString *identifier;
	NSString *locationIdentifier;
	ARLocation *location;
	ARAnchor anchor;
	ARAction *action;
	ARPoint3D offset;
	BOOL showInRadar;
}

/**
 * Starts parsing a feature using the given XML parser and start element. Notifies the given target after the end element has been parsed, passing the result as the first argument which is either an instance of the receiver or nil when parsing has failed.
 *
 * Subclasses must implement this method.
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
 * Updates the receiver's location with the location that corresponds to the receiver's location identifier.
 *
 * @param aLocation A location whose identifier must equal the receiver's location identifier.
 */
- (void)setIdentifiedLocation:(ARLocation *)aLocation;

/**
 * The identifier of the receiver, may be nil.
 */
@property(nonatomic, readonly, copy) NSString *identifier;

/**
 * The identifier of the location of the receiver, may be nil. When determining the location of this feature, check the location property before this property.
 */
@property(nonatomic, readonly, copy) NSString *locationIdentifier;

/**
 * The location of the receiver, may be nil. When determining the location of this feature, check this property before the locationIdentifier property.
 */
@property(nonatomic, readonly, retain) ARLocation *location;

/**
 * The anchor of the receiver, determines which point is positioned exactly at the indicated location.
 */
@property(nonatomic, readonly) ARAnchor anchor;

/**
 * The action that should be executed when the user taps on this feature, may be nil.
 */
@property(nonatomic, readonly, retain) ARAction *action;

/**
 * The offset in meters in ENU coordinate space from the indicated location.
 */
@property(nonatomic, readonly) ARPoint3D offset;

/**
 * Flag indicating whether this feature should be visible on the radar.
 */
@property(nonatomic, readonly) BOOL showInRadar;

@end
