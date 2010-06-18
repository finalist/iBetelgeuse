//
//  ARSpatialStateManager.h
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
#import <QuartzCore/QuartzCore.h>
#import "ARPoint3D.h"
#import "ARQuaternion.h"


@class ARSpatialState, ARLocation, ARAccelerometerFilter, AROrientationFilter;
@protocol ARSpatialStateManagerDelegate;


@interface ARSpatialStateManager : NSObject {
@private
	id <ARSpatialStateManagerDelegate> delegate;
	BOOL delegateRespondsToLocationDidUpdate;
	ARPoint3D EFToECEFSpaceOffset;

	BOOL updating;
#if TARGET_IPHONE_SIMULATOR
	NSTimer *updateTimer;
#else
	CLLocationManager *locationManager;
#endif

	BOOL locationAvailable;
	NSTimeInterval locationTimeIntervalSinceReferenceDate;
	BOOL upDirectionAvailable;
	NSTimeInterval upDirectionTimeIntervalSinceReferenceDate;
	BOOL northDirectionAvailable;
	NSTimeInterval northDirectionTimeIntervalSinceReferenceDate;
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
	CLLocationDistance altitude;
	ARPoint3D lastUpDirectionInDeviceSpace;
	ARPoint3D lastNorthDirectionInDeviceSpace;
	ARQuaternion ENUToDeviceSpaceQuaternion;
	
	ARAccelerometerFilter *upDirectionFilter;
	AROrientationFilter *orientationFilter;
	
	NSDate *timestamp;
	ARSpatialState *spatialState;
}

@property(nonatomic, assign) id <ARSpatialStateManagerDelegate> delegate;
@property(nonatomic) ARPoint3D EFToECEFSpaceOffset;

@property(nonatomic, readonly, getter=isUpdating) BOOL updating;
- (void)startUpdating;
- (void)stopUpdating;

@property(nonatomic, readonly, retain) ARSpatialState *spatialState;

@end


/**
 * Protocol that should be implemented by users of the ARSpatialStateManagerDelegate class.
 */
@protocol ARSpatialStateManagerDelegate <NSObject>

/**
 * Sent whenever the acceleration, location or heading has changed. This method will be called after spatialStateManagerLocationDidUpdate:.
 * 
 * @param manager The sender of the message.
 */
- (void)spatialStateManagerDidUpdate:(ARSpatialStateManager *)manager;

@optional

/**
 * Sent when the location has changed. This method will be called less often and therefore allows for more elaborate processing.
 */
- (void)spatialStateManagerLocationDidUpdate:(ARSpatialStateManager *)manager;

@end
