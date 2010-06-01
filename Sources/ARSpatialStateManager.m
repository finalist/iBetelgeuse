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

@synthesize delegate, EFToECEFSpaceOffset;
@synthesize updating, rawAcceleration, rawLocation, rawHeading;

#pragma mark NSObject

- (void)dealloc {
#if TARGET_IPHONE_SIMULATOR
	[updateTimer invalidate];
	[updateTimer release];
#else
	[locationManager release];
#endif
	
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
	
	if (delegateRespondsToLocationDidUpdate) {
		[delegate spatialStateManagerLocationDidUpdate:self];
	}
	[delegate spatialStateManagerDidUpdate:self];
}

#pragma mark ARSpatialStateManager

- (void)setDelegate:(id <ARSpatialStateManagerDelegate>)aDelegate {
	delegate = aDelegate;
	delegateRespondsToLocationDidUpdate = [delegate respondsToSelector:@selector(spatialStateManagerLocationDidUpdate:)];
}

- (void)startUpdating {
	if ([self isUpdating]) {
		return;
	}
	else {
		[self setUpdating:YES];
	}

#if TARGET_IPHONE_SIMULATOR
	[updateTimer invalidate];
	updateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateTimerDidFire) userInfo:nil repeats:YES] retain];
#else
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
#if TARGET_IPHONE_SIMULATOR
	[updateTimer invalidate];
	[updateTimer release];
	updateTimer = nil;
#else
	// Make sure the accelerometer stops calling us
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	if ([accelerometer delegate] == self) {
		[accelerometer setDelegate:nil];
	}

	[locationManager release];
	locationManager = nil;
#endif
	
	[self setUpdating:NO];
}

#if TARGET_IPHONE_SIMULATOR

- (void)updateTimerDidFire {
	if (delegateRespondsToLocationDidUpdate) {
		[delegate spatialStateManagerLocationDidUpdate:self];
	}
	[delegate spatialStateManagerDidUpdate:self];
}

#endif

/**
 * Compute compass declination at the current location.
 * @return an angle in range -2pi..2pi in radians.
 */
- (CGFloat)declination {
#if TARGET_IPHONE_SIMULATOR
	return -10.f/180.f*M_PI;
#else
	if (rawHeading) {
		CGFloat declination = ([rawHeading trueHeading] - [rawHeading magneticHeading]) / 180.f * M_PI;
		return declination;
	} else {
		return 0.;
	}

#endif
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

- (ARPoint3D)magneticNorthDirectionInDeviceSpace {
	if (rawHeading) {
		// The north vector is approximated using the magnetic north indicated by the magnetometer
		ARPoint3D magneticNorthDirectionInDeviceSpace = ARPoint3DCreate([rawHeading x], [rawHeading y], [rawHeading z]);
		return magneticNorthDirectionInDeviceSpace;
	}
	else {
		// Assume the back of the device is pointed towards north; add declination for testing.
		return ARPoint3DCreate(sin([self declination]), 0., -cos([self declination]));
	}
}

- (ARPoint3D)northDirectionInDeviceSpace {
	ARPoint3D upDirectionInDeviceSpace = [self upDirectionInDeviceSpace];
	ARPoint3D magneticNorthDirectionInDeviceSpace = [self magneticNorthDirectionInDeviceSpace];
	ARTransform3D declinationCorrectionTransform = CATransform3DMakeRotation([self declination], upDirectionInDeviceSpace.x, upDirectionInDeviceSpace.y, upDirectionInDeviceSpace.z);
	ARPoint3D northDirectionInDeviceSpace = ARTransform3DNonhomogeneousVectorMatrixMultiply(magneticNorthDirectionInDeviceSpace, declinationCorrectionTransform);
	return northDirectionInDeviceSpace;
}

- (ARPoint3D)northDirectionInECEFSpace {
	// By definition of ECEF, the North pole is located along the z-axis
	return ARPoint3DCreate(0., 0., 1.);
}

- (ARLocation *)location {
#if TARGET_IPHONE_SIMULATOR
	return [[[ARLocation alloc] initWithLatitude:0 longitude:0 altitude:0] autorelease];
#else
	if (rawLocation) {
		return [[[ARLocation alloc] initWithCLLocation:rawLocation] autorelease];
	}
	else {
		return nil;
	}
#endif
}

- (ARPoint3D)locationInECEFSpace {
	if (rawLocation) {
		return ARWGS84GetECEF([rawLocation coordinate].latitude, [rawLocation coordinate].longitude, [rawLocation altitude]);
	}
	else {
		// Fallback to the intersection of the equator and the prime meridian (somewhere in the Atlantic below Ghana...)
		return ARWGS84GetECEF(0, 0, 0);
	}
}

- (ARPoint3D)locationInEFSpace {
	return ARPoint3DSubtract([self locationInECEFSpace], [self EFToECEFSpaceOffset]);
}

- (CATransform3D)ENUToDeviceSpaceTransform {
	// The ENU coordinate space is defined in device coordinate space by looking:
	// * from the device, which is at [0 0 0] in device coordinates;
	// * towards the sky, which is given by the up vector; and
	// * oriented towards the North pole, which is given by the north vector.
	return ARTransform3DLookAtRelative(ARPoint3DZero, [self upDirectionInDeviceSpace], [self northDirectionInDeviceSpace], ARPoint3DZero);
}

- (CATransform3D)ENUToEFSpaceTransform {
	// The ENU coordinate space is defined in ECEF coordinate space by looking:
	// * from the device, which is given by the GPS after conversion to ECEF;
	// * towards the sky, which is the same vector as the ECEF position since the ECEF origin is defined to be at the Earth's center; and
	// * oriented towards the North pole, which is defined to be the z-axis of the ECEF coordinate system.
	return ARTransform3DLookAtRelative([self locationInEFSpace], [self upDirectionInEFSpace], [self northDirectionInECEFSpace], ARPoint3DZero);
}

- (CATransform3D)EFToENUSpaceTransform {
	return CATransform3DInvert([self ENUToEFSpaceTransform]);
}

- (ARPoint3D)upDirectionInEFSpace {
	return [self locationInECEFSpace];
}

- (CLLocationDistance)altitude {
	return [rawLocation altitude];
}

@end
