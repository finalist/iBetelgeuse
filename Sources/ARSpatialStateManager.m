//
//  ARSpatialStateManager.m
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

#import "ARSpatialStateManager.h"
#import "ARLocation.h"
#import "ARTransform3D.h"
#import "ARWGS84.h"


#define ACCELEROMETER_UPDATE_FREQUENCY 30 // Hz
#define LOCATION_EXPIRATION 60 // seconds


@interface ARSpatialStateManager ()

@property(nonatomic, readwrite, getter=isUpdating) BOOL updating;
@property(nonatomic, readwrite, retain) UIAcceleration *rawAcceleration;
@property(nonatomic, readwrite, retain) CLLocation *rawLocation;
@property(nonatomic, readwrite, retain) CLHeading *rawHeading;

- (ARPoint3D)upDirectionInDeviceSpace;
- (ARPoint3D)northDirectionInDeviceSpace;
- (ARPoint3D)northDirectionInECEFSpace;

@end


@implementation ARSpatialStateManager

@synthesize delegate;
@synthesize updating, rawAcceleration, rawLocation, rawHeading;

#pragma mark NSObject

- (void)dealloc {
	[locationManager release];
	
	[rawAcceleration release];
	[rawLocation release];
	[rawHeading release];
	
	[super dealloc];
}

#pragma mark UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)newRawAcceleration {
	[self setRawAcceleration:newRawAcceleration];
	
	[delegate spatialStateManagerDidUpdate:self];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newRawHeading {
	[self setRawHeading:newRawHeading];
	
	[delegate spatialStateManagerDidUpdate:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newRawLocation fromLocation:(CLLocation *)previousRawLocation {
	// Ignore invalid or old locations
	if (signbit([newRawLocation horizontalAccuracy]) || [[newRawLocation timestamp] timeIntervalSinceNow] < -LOCATION_EXPIRATION) {
		return;
	}
	
	DebugLog(@"Got location location fix: %@", newRawLocation);
	
	[self setRawLocation:newRawLocation];
	
	[delegate spatialStateManagerDidUpdate:self];
}

#pragma mark ARSpatialStateManager

- (void)startUpdating {
	if ([self isUpdating]) {
		return;
	}
	else {
		[self setUpdating:YES];
	}

#if !TARGET_IPHONE_SIMULATOR
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	[accelerometer setDelegate:self];
	[accelerometer setUpdateInterval:1. / ACCELEROMETER_UPDATE_FREQUENCY];

	[locationManager release];
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDelegate:self];
	[locationManager setDistanceFilter:kCLDistanceFilterNone];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[locationManager startUpdatingLocation];
	if ([locationManager headingAvailable]) {
		[locationManager startUpdatingHeading];
	}
#endif
}

- (void)stopUpdating {
	[locationManager release];
	locationManager = nil;
	
	[self setUpdating:NO];
}

- (ARPoint3D)upDirectionInDeviceSpace {
	if (rawAcceleration) {
		// The up vector is opposite to the gravity indicated by the accelerometer
		return ARPoint3DCreate(-[rawAcceleration x], -[rawAcceleration y], -[rawAcceleration z]);
	}
	else {
		// Assume the device is being held perpendicular to the floor with the home button to the bottom
		return ARPoint3DCreate(0., 1., 0.);
	}
}

- (ARPoint3D)northDirectionInDeviceSpace {
	if (rawHeading) {
		// The north vector is approximated using the magnetic north indicated by the magnetometer
		return ARPoint3DCreate([rawHeading x], [rawHeading y], [rawHeading z]);
	}
	else {
		// Assume the back of the device is pointed towards magnetic north
		return ARPoint3DCreate(0., 0., -1.);
	}
}

- (ARPoint3D)northDirectionInECEFSpace {
	// By definition of ECEF, the North pole is located along the z-axis
	return ARPoint3DCreate(0., 0., 1.);
}

- (ARLocation *)location {
	if (rawLocation) {
		return [[[ARLocation alloc] initWithCLLocation:rawLocation] autorelease];
	}
	else {
		return nil;
	}
}

- (ARPoint3D)locationAsECEFCoordinate {
	if (rawLocation) {
		return ARWGS84GetECEF([rawLocation coordinate].latitude, [rawLocation coordinate].longitude, [rawLocation altitude]);
	}
	else {
		// Fallback to the intersection of the equator and the prime meridian (somewhere in the Atlantic below Ghana...)
		return ARWGS84GetECEF(0, 0, 0);
	}
}

- (CATransform3D)ENUToDeviceSpaceTransform {
	// The ENU coordinate space is defined in device coordinate space by looking:
	// * from the device, which is at [0 0 0] in device coordinates;
	// * towards the sky, which is given by the up vector; and
	// * oriented towards the North pole, which is given by the north vector.
	return ARTransform3DLookAtRelative(ARPoint3DZero, [self upDirectionInDeviceSpace], [self northDirectionInDeviceSpace], ARPoint3DZero);
}

- (CATransform3D)ENUToECEFSpaceTransform {
	// The ENU coordinate space is defined in ECEF coordinate space by looking:
	// * from the device, which is given by the GPS after conversion to ECEF;
	// * towards the sky, which is the same vector as the ECEF position since the ECEF origin is defined to be at the Earth's center; and
	// * oriented towards the North pole, which is defined to be the z-axis of the ECEF coordinate system.
	return ARTransform3DLookAtRelative([self locationAsECEFCoordinate], [self locationAsECEFCoordinate], [self northDirectionInECEFSpace], ARPoint3DZero);
}

- (CATransform3D)ECEFToENUSpaceTransform {
	return CATransform3DInvert([self ENUToECEFSpaceTransform]);
}

- (CLLocationDistance)altitude {
	return [rawLocation altitude];
}

@end
