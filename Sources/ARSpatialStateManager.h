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
#import "ARPoint3D.h"
#import "ARQuaternion.h"


#define SPATIAL_STATE_MANAGER_MODE_DEVICE 0
#define SPATIAL_STATE_MANAGER_MODE_SIMULATOR 1
#define SPATIAL_STATE_MANAGER_MODE_TEST 2


#if TARGET_OS_IPHONE
	#if TARGET_IPHONE_SIMULATOR
		#define SPATIAL_STATE_MANAGER_MODE SPATIAL_STATE_MANAGER_MODE_SIMULATOR
	#else
		#define SPATIAL_STATE_MANAGER_MODE SPATIAL_STATE_MANAGER_MODE_DEVICE
	#endif
#else
	#define SPATIAL_STATE_MANAGER_MODE SPATIAL_STATE_MANAGER_MODE_TEST
#endif


@class ARSpatialState, ARAccelerometerFilter, AROrientationFilter;
@protocol ARSpatialStateManagerDelegate;


/**
 * Class that continuously determines the spatial state (location and orientation) of the device on Earth.
 */
@interface ARSpatialStateManager : NSObject {
@private
	id <ARSpatialStateManagerDelegate> delegate;
	BOOL delegateRespondsToLocationDidUpdate;
	ARPoint3D EFToECEFSpaceOffset;

	BOOL updating;
#if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_DEVICE
	CLLocationManager *locationManager;
#else if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_SIMULATOR
	NSTimer *updateTimer;
#endif
	
	ARAccelerometerFilter *upDirectionFilter;
	AROrientationFilter *orientationFilter;

	// Details about the last determined location
	BOOL locationAvailable;
	BOOL locationReliable;
	NSTimeInterval locationTimeIntervalSinceReferenceDate;
	CLLocationDistance locationAccuracy;
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
	CLLocationDistance altitude;
	
	// Details about the last determined up direction
	BOOL upDirectionAvailable;
	ARPoint3D lastUpDirectionInDeviceSpace;
	
	// Details about the last determined north direction
	BOOL northDirectionAvailable;
	ARPoint3D lastNorthDirectionInDeviceSpace;
	
	// Details about the last determined orientation
	BOOL orientationAvailable;
	NSTimeInterval orientationTimeIntervalSinceReferenceDate;
	ARQuaternion ENUToDeviceSpaceQuaternion;
	
	// Details about the current spatial state
	NSDate *timestamp;
	ARSpatialState *spatialState;
}

/**
 * The receiver's delegate.
 */
@property(nonatomic, assign) id <ARSpatialStateManagerDelegate> delegate;

/**
 * The offset between Earth-Fixed space and Earth-Centered Earth-Fixed space.
 *
 * Usually, this offset (and thus the origin of the Earth-Fixed coordinate space) should be set somewhere close to the device's current location. This makes it possible to describe locations that are close to the device with sufficient precision in Earth-Fixed space. In contrast, when expressing locations in Earth-Centered Earth-Fixed space, the radius of Earth quickly depletes the precision of a 32-bit floating point number.
 */
@property(nonatomic) ARPoint3D EFToECEFSpaceOffset;

/**
 * Flag indicating whether the receiver is currently updating.
 */
@property(nonatomic, readonly, getter=isUpdating) BOOL updating;

/**
 * Starts determining the spatial state of the device at regular intervals and notifying the delegate about changes. When the receiver is already updating, this method has no effect. As long as the receiver is updating, no other classes should attempt to use the UIAccelerometer.
 */
- (void)startUpdating;

/**
 * Stops determining the spatial state of the device and notifying the delegate. When the receiver is not updating, this method has no effect.
 */
- (void)stopUpdating;

/**
 * The current spatial state as determined by the receiver. Check the locationAvailable, locationReliable, orientationAvailable and orientationReliable of the returned object to validate the quality of the spatial state.
 */
@property(nonatomic, readonly, retain) ARSpatialState *spatialState;

@end


/**
 * Protocol that should be implemented by users of the ARSpatialStateManagerDelegate class in order to receive updates about changes to the spatial state.
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
 * Sent when the location has changed. This method will be called less often than spatialStateManagerDidUpdate: and therefore allows for more elaborate processing.
 *
 * @param manager The sender of the message.
 */
- (void)spatialStateManagerLocationDidUpdate:(ARSpatialStateManager *)manager;

@end
