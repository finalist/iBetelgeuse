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
#import "ARTransform3D.h"
#import "ARWGS84.h"

@implementation ARSpatialStateManager

@synthesize delegate;
@synthesize rawAcceleration, rawLocation, rawHeading;

#pragma mark NSObject

- (void)dealloc {
	[super dealloc];
	[locationManager release];
	
	[rawAcceleration release];
	[rawLocation release];
	[rawHeading release];
}

#pragma mark UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)newRawAcceleration {
	[rawAcceleration release];
	rawAcceleration = [newRawAcceleration retain];
	
	[delegate spatialStateManagerDidUpdate:self];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newRawHeading {
	[rawHeading release];
	rawHeading = [newRawHeading retain];
	
	[delegate spatialStateManagerDidUpdate:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newRawLocation fromLocation:(CLLocation *)previousRawLocation {
	[rawLocation release];
	rawLocation = [newRawLocation retain];
	
	DebugLog(@"Got location location fix: %@", newRawLocation);
	
	[delegate spatialStateManagerDidUpdate:self];
}

#pragma mark ARSpatialStateManager

- (void)startUpdating {
	NSAssert(!accelerometer, @"Spatial state manager updating has already been started.");
	NSAssert(!locationManager, nil);
	
	accelerometer = [UIAccelerometer sharedAccelerometer];
	[accelerometer setDelegate:self];
	[accelerometer setUpdateInterval:.001];
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDelegate:self];
	[locationManager startUpdatingLocation];
	[locationManager startUpdatingHeading];
}

- (void)stopUpdating {
	accelerometer = nil;
	
	[locationManager release];
	locationManager = nil;
}

- (ARPoint3D)upDirectionInDeviceCoordinates {
	if (!rawAcceleration)
		return ARPoint3DCreate(0., 1., 0.);
	return ARPoint3DCreate(-[rawAcceleration x], -[rawAcceleration y], -[rawAcceleration z]);
}

- (ARPoint3D)northDirectionInDeviceCoordinates {
	if (!rawHeading)
		return ARPoint3DCreate(0., 0., 1.);
	return ARPoint3DCreate([rawHeading x], [rawHeading y], [rawHeading z]);
}

- (ARPoint3D)northDirectionInEcefCoordinates {
	return ARPoint3DCreate(0., 0., 1.);
}

- (ARPoint3D)positionInEcefCoordinates {
	return ARWGS84GetECEF([rawLocation coordinate].latitude, [rawLocation coordinate].longitude, [rawLocation altitude]);
}

- (CATransform3D)enuToDeviceTransform {
	return ARTransform3DLookAtRelative(ARPoint3DZero, [self upDirectionInDeviceCoordinates], [self northDirectionInDeviceCoordinates]);
}

- (CATransform3D)enuToEcefTransform {
	return ARTransform3DLookAtRelative([self positionInEcefCoordinates], [self positionInEcefCoordinates], [self northDirectionInEcefCoordinates]);
}

- (CATransform3D)ecefToEnuTransform {
	return CATransform3DInvert([self enuToEcefTransform]);
}

@end
