//
//  ARSpatialState.h
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

#import <CoreLocation/CoreLocation.h>
#import "ARQuaternion.h"
#import "ARPoint3D.h"
#import "ARTransform3D.h"

@class ARLocation;


/**
 * This class contains the current spatial state (location and orientation) and
 * has various methods to get this state in different formats and coordinate
 * spaces. Additionally, it employs caching for most of these values, so that
 * they only have to be computed once. This class is immutable, apart from the
 * cache updates.
 */
@interface ARSpatialState : NSObject {
@private
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
	CLLocationDistance altitude;
	ARQuaternion ENUToDeviceSpaceQuaternion;
	ARPoint3D EFToECEFSpaceOffset;
	NSDate *timestamp;
	
	ARLocation *location;
	ARPoint3D locationInECEFSpace;
	ARPoint3D upDirectionInDeviceSpace;
	ARPoint3D northDirectionInDeviceSpace;
	CATransform3D ENUToDeviceSpaceTransform;
	CATransform3D DeviceToENUSpaceTransform;
	CATransform3D ENUToEFSpaceTransform;
	CATransform3D EFToENUSpaceTransform;
	
	struct {
		BOOL locationAvailable:1;
		BOOL locationReliable:1;
		BOOL orientationAvailable:1;
		BOOL orientationReliable:1;
		BOOL haveUpDirectionInDeviceSpace:1;
		BOOL haveNorthDirectionInDeviceSpace:1;
		BOOL haveLocationInECEFSpace:1;
		BOOL haveENUToDeviceSpaceTransform:1;
		BOOL haveDeviceToENUSpaceTransform:1;
		BOOL haveENUToEFSpaceTransform:1;
		BOOL haveEFToENUSpaceTransform:1;
	} flags;
}


/**
 * YES iff the current location could be determined.
 */
@property(nonatomic, readonly, getter=isLocationAvailable) BOOL locationAvailable;

/**
 * YES iff the location is recent and is considered sufficiently accurate.
 */
@property(nonatomic, readonly, getter=isLocationReliable) BOOL locationReliable;

/**
 * YES iff the current orientation is available.
 */
@property(nonatomic, readonly, getter=isOrientationAvailable) BOOL orientationAvailable;

/**
 * YES iff the orientation is recent.
 */
@property(nonatomic, readonly, getter=isOrientationReliable) BOOL orientationReliable;

/**
 * The time at which this spatial state was determined.
 */
@property(nonatomic, readonly, retain) NSDate *timestamp;


/**
 * The current location.
 */
@property(nonatomic, readonly, retain) ARLocation *location;

/**
 * The current altitude.
 */
@property(nonatomic, readonly) CLLocationDistance altitude;

/**
 * The current location in ECEF coordinate space.
 */
@property(nonatomic, readonly) ARPoint3D locationInECEFSpace;

/**
 * The current location in EF coordinate space.
 */
@property(nonatomic, readonly) ARPoint3D locationInEFSpace;


/**
 * The current bearing, in range [-pi..pi]. The bearing increases in a clockwise
 * direction (90 degrees = east).
 */
@property(nonatomic, readonly) double bearing;

/**
 * The current pitch, in range [-pi..pi]. The pitch is positive for upwards
 * angles (90 degrees = straight up, towards the sky).
 */
@property(nonatomic, readonly) double pitch;

/**
 * The current roll, in range [-pi..pi]. The roll is positive for a counter-
 * clockwise orientation (0 degrees = top of the device points towards the sky;
 * 90 degrees = top of the device points left).
 */
@property(nonatomic, readonly) double roll;


/**
 * The current up direction in device space. This is similar to the negation of
 * the accelerometer sensor's readings, but after filtering.
 */
@property(nonatomic, readonly) ARPoint3D upDirectionInDeviceSpace;

/**
 * The current up direction in ENU space. This is [0, 0, 1] by definition.
 */
@property(nonatomic, readonly) ARPoint3D upDirectionInENUSpace;

/**
 * The current up direction in ECEF space.
 */
@property(nonatomic, readonly) ARPoint3D upDirectionInECEFSpace;

/**
 * The current up direction in EF space.
 */
@property(nonatomic, readonly) ARPoint3D upDirectionInEFSpace;


/**
 * The current direction towards the true North in device space. This would be
 * the value returned by the magnetometer, if the data would be unfiltered and
 * no declination correction would have been performed. Note that this does not
 * have to represent the same vector as north direction vectors defined in other
 * coordinate spaces, due to different inclinations (which should be ignored by
 * the application)!
 */
@property(nonatomic, readonly) ARPoint3D northDirectionInDeviceSpace;

/**
 * The current direction towards the true North in ENU space. This is [0, 1, 0]
 * by definition. Note that this does not have to represent the same vector as
 * north direction vectors defined in other coordinate spaces, due to different
 * inclinations (which should be ignored by the application)!
 */
@property(nonatomic, readonly) ARPoint3D northDirectionInENUSpace;

/**
 * The current direction towards the true North in ECEF space. This is [0, 0, 1]
 * by definition. Note that this does not have to represent the same vector as
 * north direction vectors defined in other coordinate spaces, due to different
 * inclinations (which should be ignored by the application)!
 */
@property(nonatomic, readonly) ARPoint3D northDirectionInECEFSpace;

/**
 * The current direction towards the true North in EF space. This is [0, 0, 1]
 * by definition. Note that this does not have to represent the same vector as
 * north direction vectors defined in other coordinate spaces, due to different
 * inclinations (which should be ignored by the application)!
 */
@property(nonatomic, readonly) ARPoint3D northDirectionInEFSpace;


/**
 * The transformation matrix to convert points in ENU space to points in device
 * space.
 */
@property(nonatomic, readonly) CATransform3D ENUToDeviceSpaceTransform;

/**
 * The transformation matrix to convert points in device space to points in ENU
 * space.
 */
@property(nonatomic, readonly) CATransform3D DeviceToENUSpaceTransform;

/**
 * The transformation matrix to convert points in ENU space to points in EF
 * space.
 */
@property(nonatomic, readonly) CATransform3D ENUToEFSpaceTransform;

/**
 * The transformation matrix to convert points in EF space to points in ENU
 * space.
 */
@property(nonatomic, readonly) CATransform3D EFToENUSpaceTransform;

/**
 * The translation vector to convert points in EF space to points in ECEF
 * space.
 */
@property(nonatomic, readonly) ARPoint3D EFToECEFSpaceOffset;

/**
 * Initialize the spatial state.
 * @param locationAvailable YES iff the current location could be determined.
 * @param locationReliable YES iff the location is recent and is considered sufficiently accurate.
 * @param latitude the current WGS84 latitude, can be anything if locationAvailable is NO.
 * @param longitude the current WGS84 longitude, can be anything if locationAvailable is NO.
 * @param altitude the current WGS84 altitude, can be anything if locationAvailable is NO.
 * @param orientationAvailable YES iff the current orientation could be determined.
 * @param isOrientationReliable YES iff the current orientation is recent.
 * @param anENUToDeviceSpaceQuaternion a quaternion indicating the current device's orientation, defined in ENU space.
 * @param EFToECEFSpaceOffset the offset between EF and ECEF space.
 * @param timestamp the time at which this spatial state was determined. May not be nil.
 * @return the spatial state.
 */
- (id)initWithLocationAvailable:(BOOL)locationAvailable
					   reliable:(BOOL)locationReliable
					   latitude:(CLLocationDegrees)latitude
					  longitude:(CLLocationDegrees)longitude
					   altitude:(CLLocationDistance)altitude
		   orientationAvailable:(BOOL)orientationAvailable
					   reliable:(BOOL)isOrientationReliable
	 ENUToDeviceSpaceQuaternion:(ARQuaternion)anENUToDeviceSpaceQuaternion
			EFToECEFSpaceOffset:(ARPoint3D)EFToECEFSpaceOffset
					  timestamp:(NSDate *)timestamp;

@end
