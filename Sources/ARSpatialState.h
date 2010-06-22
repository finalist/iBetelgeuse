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

@property(nonatomic, readonly, getter=isLocationAvailable) BOOL locationAvailable;
@property(nonatomic, readonly, getter=isLocationReliable) BOOL locationReliable;
@property(nonatomic, readonly, getter=isOrientationAvailable) BOOL orientationAvailable;
@property(nonatomic, readonly, getter=isOrientationReliable) BOOL orientationReliable;
@property(nonatomic, readonly, retain) NSDate *timestamp;

@property(nonatomic, readonly, retain) ARLocation *location;
@property(nonatomic, readonly) CLLocationDistance altitude;
@property(nonatomic, readonly) ARPoint3D locationInECEFSpace;
@property(nonatomic, readonly) ARPoint3D locationInEFSpace;
@property(nonatomic, readonly) CLLocationDegrees bearing;
@property(nonatomic, readonly) CLLocationDegrees pitch;
@property(nonatomic, readonly) CLLocationDegrees roll;

@property(nonatomic, readonly) ARPoint3D upDirectionInDeviceSpace;
@property(nonatomic, readonly) ARPoint3D upDirectionInECEFSpace;
@property(nonatomic, readonly) ARPoint3D upDirectionInEFSpace;

@property(nonatomic, readonly) ARPoint3D northDirectionInDeviceSpace;
@property(nonatomic, readonly) ARPoint3D northDirectionInECEFSpace;
@property(nonatomic, readonly) ARPoint3D northDirectionInEFSpace;

@property(nonatomic, readonly) CATransform3D ENUToDeviceSpaceTransform;
@property(nonatomic, readonly) CATransform3D DeviceToENUSpaceTransform;
@property(nonatomic, readonly) CATransform3D ENUToEFSpaceTransform;
@property(nonatomic, readonly) CATransform3D EFToENUSpaceTransform;
@property(nonatomic, readonly) ARPoint3D EFToECEFSpaceOffset;

- (id)initWithLocationAvailable:(BOOL)locationAvailable
						 reliable:(BOOL)locationRecent
					   latitude:(CLLocationDegrees)latitude
					  longitude:(CLLocationDegrees)longitude
					   altitude:(CLLocationDistance)altitude
		   orientationAvailable:(BOOL)orientationAvailable
					   reliable:(BOOL)isOrientationRecent
	 ENUToDeviceSpaceQuaternion:(ARQuaternion)anENUToDeviceSpaceQuaternion
			EFToECEFSpaceOffset:(ARPoint3D)EFToECEFSpaceOffset
					  timestamp:(NSDate *)timestamp;

@end
