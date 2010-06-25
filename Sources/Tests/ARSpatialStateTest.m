//
//  ARSpatialStateTest.m
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

#import "ARSpatialStateTest.h"
#import "ARSpatialState.h"
#import "ARLocation.h"
#import "ARWGS84.h"
#import "ARPoint3D.h"
#import "ARTransform3D.h"


@interface ARSpatialStateTest ()

- (ARQuaternion)quaternionWithBearing:(double)bearing pitch:(double)pitch roll:(double)roll;

@end


@implementation ARSpatialStateTest

#pragma mark GHTestCase

- (void)testInitWithValuesAndTestSimpleProperties {
	ARPoint3D EFToECEFSpaceOffset;
	NSDate *timestamp;
	ARSpatialState *s;
	ARPoint3D locationInECEFSpace;
	
	// Test with invalid timestamp
	GHAssertThrows([[[ARSpatialState alloc] initWithLocationAvailable:YES 
															 reliable:YES 
															 latitude:0. 
															longitude:0. 
															 altitude:10. 
												 orientationAvailable:YES 
															 reliable:YES 
										   ENUToDeviceSpaceQuaternion:ARQuaternionIdentity
												  EFToECEFSpaceOffset:EFToECEFSpaceOffset 
															timestamp:nil] release], nil);
	
	timestamp = [NSDate dateWithTimeIntervalSince1970:3600.];
	
	// Test with different latitudes and longitudes
	GHAssertThrows([[[ARSpatialState alloc] initWithLocationAvailable:YES 
															 reliable:YES 
															 latitude:91. 
															longitude:0. 
															 altitude:10. 
												 orientationAvailable:YES 
															 reliable:YES 
										   ENUToDeviceSpaceQuaternion:ARQuaternionIdentity
												  EFToECEFSpaceOffset:EFToECEFSpaceOffset 
															timestamp:timestamp] release], nil);
	GHAssertThrows([[[ARSpatialState alloc] initWithLocationAvailable:YES 
															 reliable:YES 
															 latitude:0. 
															longitude:181. 
															 altitude:10. 
												 orientationAvailable:YES 
															 reliable:YES 
										   ENUToDeviceSpaceQuaternion:ARQuaternionIdentity
												  EFToECEFSpaceOffset:EFToECEFSpaceOffset 
															timestamp:timestamp] release], nil);
	GHAssertThrows([[[ARSpatialState alloc] initWithLocationAvailable:YES 
															 reliable:YES 
															 latitude:-91. 
															longitude:0. 
															 altitude:10. 
												 orientationAvailable:YES 
															 reliable:YES 
										   ENUToDeviceSpaceQuaternion:ARQuaternionIdentity
												  EFToECEFSpaceOffset:EFToECEFSpaceOffset 
															timestamp:timestamp] release], nil);
	GHAssertThrows([[[ARSpatialState alloc] initWithLocationAvailable:YES 
															 reliable:YES 
															 latitude:0. 
															longitude:-181. 
															 altitude:10. 
												 orientationAvailable:YES 
															 reliable:YES 
										   ENUToDeviceSpaceQuaternion:ARQuaternionIdentity
												  EFToECEFSpaceOffset:EFToECEFSpaceOffset 
															timestamp:timestamp] release], nil);
	GHAssertNoThrow([[[ARSpatialState alloc] initWithLocationAvailable:YES 
															 reliable:YES 
															 latitude:-90. 
															longitude:-180. 
															 altitude:10. 
												 orientationAvailable:YES 
															 reliable:YES 
										   ENUToDeviceSpaceQuaternion:ARQuaternionIdentity
												  EFToECEFSpaceOffset:EFToECEFSpaceOffset 
															timestamp:timestamp] release], nil);
	GHAssertNoThrow([[[ARSpatialState alloc] initWithLocationAvailable:YES 
															 reliable:YES 
															 latitude:90. 
															longitude:180. 
															 altitude:10. 
												 orientationAvailable:YES 
															 reliable:YES 
										   ENUToDeviceSpaceQuaternion:ARQuaternionIdentity
												  EFToECEFSpaceOffset:EFToECEFSpaceOffset 
															timestamp:timestamp] release], nil);
	
	// Test with one good set of values
	EFToECEFSpaceOffset = ARPoint3DMake(10., 10., 10.);
	timestamp = [NSDate dateWithTimeIntervalSince1970:3600.];
	s = [[ARSpatialState alloc] initWithLocationAvailable:YES 
												 reliable:YES 
												 latitude:45. 
												longitude:45. 
												 altitude:-10. 
									 orientationAvailable:YES 
												 reliable:YES 
							   ENUToDeviceSpaceQuaternion:ARQuaternionIdentity
									  EFToECEFSpaceOffset:EFToECEFSpaceOffset 
												timestamp:timestamp];
	
	locationInECEFSpace = ARPoint3DMake(3194414., 3194414., 4487341.);
	GHAssertTrue([s isLocationAvailable], nil);
	GHAssertTrue([s isLocationReliable], nil);
	GHAssertTrue([s isOrientationAvailable], nil);
	GHAssertTrue([s isOrientationReliable], nil);
	GHAssertEqualObjects([s timestamp], timestamp, nil);
	GHAssertEquals([[s location] latitude], (CLLocationDegrees)45., nil);
	GHAssertEquals([[s location] longitude], (CLLocationDegrees)45., nil);
	GHAssertEquals([[s location] altitude], (CLLocationDistance)-10, nil);
	GHAssertEquals([s altitude], (CLLocationDistance)-10., nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy([s locationInECEFSpace], locationInECEFSpace, 0.5), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy([s locationInEFSpace], ARPoint3DSubtract(locationInECEFSpace, EFToECEFSpaceOffset), 0.5), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARPoint3DNormalize([s upDirectionInENUSpace]), ARPoint3DMake(0., 0., 1.), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARPoint3DNormalize([s upDirectionInECEFSpace]), ARPoint3DNormalize(locationInECEFSpace), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARPoint3DNormalize([s upDirectionInEFSpace]), ARPoint3DNormalize(locationInECEFSpace), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARPoint3DNormalize([s northDirectionInENUSpace]), ARPoint3DMake(0., 1., 0.), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARPoint3DNormalize([s northDirectionInECEFSpace]), ARPoint3DMake(0., 0., 1.), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARPoint3DNormalize([s northDirectionInEFSpace]), ARPoint3DMake(0., 0., 1.), 1e-6), nil);
	GHAssertTrue(ARPoint3DEquals([s EFToECEFSpaceOffset], EFToECEFSpaceOffset), nil);
	
	// Check some lazily loaded properties again
	GHAssertEquals([[s location] latitude], (CLLocationDegrees)45., nil);
	GHAssertEquals([[s location] longitude], (CLLocationDegrees)45., nil);
	GHAssertEquals([[s location] altitude], (CLLocationDistance)-10., nil);
	GHAssertEquals([s altitude], (CLLocationDistance)-10., nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy([s locationInECEFSpace], locationInECEFSpace, 0.5), nil);
	
	[s release];

	// Test with a another good set of values
	EFToECEFSpaceOffset = ARPoint3DMake(20., 20., 20.);
	timestamp = [NSDate dateWithTimeIntervalSince1970:86400.];
	s = [[ARSpatialState alloc] initWithLocationAvailable:NO 
												 reliable:NO 
												 latitude:45. 
												longitude:45. 
												 altitude:-10. 
									 orientationAvailable:NO 
												 reliable:NO 
							   ENUToDeviceSpaceQuaternion:ARQuaternionIdentity 
									  EFToECEFSpaceOffset:EFToECEFSpaceOffset 
												timestamp:timestamp];

	GHAssertFalse([s isLocationAvailable], nil);
	GHAssertFalse([s isLocationReliable], nil);
	GHAssertFalse([s isOrientationAvailable], nil);
	GHAssertFalse([s isOrientationReliable], nil);
	GHAssertEqualObjects([s timestamp], timestamp, nil);
	GHAssertNil([s location], nil);
	
	// Check some lazily loaded properties again
	GHAssertNil([s location], nil);
	
	[s release];
}

- (void)testBearingPitchAndRoll {
	ARSpatialState *s;
	
	// Test a case where the device is not near horizontal
	s = [[ARSpatialState alloc] initWithLocationAvailable:YES 
												 reliable:YES
												 latitude:0.
												longitude:0.
												 altitude:0.
									 orientationAvailable:YES
												 reliable:YES
							   ENUToDeviceSpaceQuaternion:[self quaternionWithBearing:0.2 pitch:0.2 roll:0.2]
									  EFToECEFSpaceOffset:ARPoint3DZero
												timestamp:[NSDate date]];
	GHAssertEqualsWithAccuracy([s bearing], 0.2, 1e-6, nil);
	GHAssertEqualsWithAccuracy([s pitch], 0.2, 1e-6, nil);
	GHAssertEqualsWithAccuracy([s roll], 0.2, 1e-6, nil);
	[s release];
	
	// Test a case where the device is near horizontal
	s = [[ARSpatialState alloc] initWithLocationAvailable:YES 
												 reliable:YES
												 latitude:0.
												longitude:0.
												 altitude:0.
									 orientationAvailable:YES
												 reliable:YES
							   ENUToDeviceSpaceQuaternion:[self quaternionWithBearing:0.2 pitch:M_PI / 2. roll:0.3]
									  EFToECEFSpaceOffset:ARPoint3DZero
												timestamp:[NSDate date]];
	// Note: when the device is horizontal, roll is incorporated int the bearing
	GHAssertEqualsWithAccuracy([s bearing], 0.5, 1e-6, nil);
	GHAssertEqualsWithAccuracy([s pitch], M_PI / 2., 1e-6, nil);
	GHAssertEqualsWithAccuracy([s roll], 0.0, 1e-6, nil);
	[s release];	
}

- (void)testUpDirectionInDeviceSpace {
	ARSpatialState *s;
	
	s = [[ARSpatialState alloc] initWithLocationAvailable:YES 
												 reliable:YES
												 latitude:0.
												longitude:0.
												 altitude:0.
									 orientationAvailable:YES
												 reliable:YES
							   ENUToDeviceSpaceQuaternion:[self quaternionWithBearing:0.0 pitch:0.0 roll:M_PI / 2.]
									  EFToECEFSpaceOffset:ARPoint3DZero
												timestamp:[NSDate date]];
	// Note: assert twice to ensure lazy calculation is working
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARPoint3DNormalize([s upDirectionInDeviceSpace]), ARPoint3DMake(1., 0., 0.), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARPoint3DNormalize([s upDirectionInDeviceSpace]), ARPoint3DMake(1., 0., 0.), 1e-6), nil);
	[s release];
}

- (void)testNorthDirectionInDeviceSpace {
	ARSpatialState *s;
	
	s = [[ARSpatialState alloc] initWithLocationAvailable:YES 
												 reliable:YES
												 latitude:0.
												longitude:0.
												 altitude:0.
									 orientationAvailable:YES
												 reliable:YES
							   ENUToDeviceSpaceQuaternion:[self quaternionWithBearing:M_PI / 2. pitch:M_PI / 2. roll:0.0]
									  EFToECEFSpaceOffset:ARPoint3DZero
												timestamp:[NSDate date]];
	// Note: assert twice to ensure lazy calculation is working
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARPoint3DNormalize([s northDirectionInDeviceSpace]), ARPoint3DMake(-1., 0., 0.), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARPoint3DNormalize([s northDirectionInDeviceSpace]), ARPoint3DMake(-1., 0., 0.), 1e-6), nil);
	[s release];
}

- (void)testENUToDeviceSpaceTransformAndInverse {
	ARSpatialState *s;
	
	s = [[ARSpatialState alloc] initWithLocationAvailable:YES 
												 reliable:YES
												 latitude:0.
												longitude:0.
												 altitude:0.
									 orientationAvailable:YES
												 reliable:YES
							   ENUToDeviceSpaceQuaternion:[self quaternionWithBearing:0.0 pitch:0.0 roll:0.0]
									  EFToECEFSpaceOffset:ARPoint3DZero
												timestamp:[NSDate date]];
	// Note: assert twice to ensure lazy calculation is working
	GHAssertTrue(ARTransform3DEqualsWithAccuracy([s ENUToDeviceSpaceTransform], CATransform3DMakeRotation(-M_PI / 2., 1., 0., 0.), 1e-6), nil);
	GHAssertTrue(ARTransform3DEqualsWithAccuracy([s ENUToDeviceSpaceTransform], CATransform3DMakeRotation(-M_PI / 2., 1., 0., 0.), 1e-6), nil);
	GHAssertTrue(ARTransform3DEqualsWithAccuracy([s DeviceToENUSpaceTransform], CATransform3DMakeRotation(M_PI / 2., 1., 0., 0.), 1e-6), nil);
	GHAssertTrue(ARTransform3DEqualsWithAccuracy([s DeviceToENUSpaceTransform], CATransform3DMakeRotation(M_PI / 2., 1., 0., 0.), 1e-6), nil);
	[s release];
}

- (void)testENUToEFSpaceTransformAndInverse {
	ARSpatialState *s;
	
	s = [[ARSpatialState alloc] initWithLocationAvailable:YES 
												 reliable:YES
												 latitude:0.
												longitude:0.
												 altitude:0.
									 orientationAvailable:YES
												 reliable:YES
							   ENUToDeviceSpaceQuaternion:ARQuaternionIdentity
									  EFToECEFSpaceOffset:ARPoint3DZero
												timestamp:[NSDate date]];
	// Note: assert twice to ensure lazy calculation is working
	GHAssertTrue(ARTransform3DEqualsWithAccuracy([s EFToENUSpaceTransform], ARTransform3DLookAtRelative(ARPoint3DMake(0., 0., -ARWGS84SemiMajorAxis), ARPoint3DMake(0., 1., 0.), ARPoint3DMake(1., 0., 0.), ARPoint3DZero), 1e-6), nil);
	GHAssertTrue(ARTransform3DEqualsWithAccuracy([s EFToENUSpaceTransform], ARTransform3DLookAtRelative(ARPoint3DMake(0., 0., -ARWGS84SemiMajorAxis), ARPoint3DMake(0., 1., 0.), ARPoint3DMake(1., 0., 0.), ARPoint3DZero), 1e-6), nil);
	GHAssertTrue(ARTransform3DEqualsWithAccuracy([s ENUToEFSpaceTransform], ARTransform3DLookAtRelative(ARPoint3DMake(ARWGS84SemiMajorAxis, 0., 0.), ARPoint3DMake(1., 0., 0.), ARPoint3DMake(0., 0., 1.), ARPoint3DZero), 1e-6), nil);
	GHAssertTrue(ARTransform3DEqualsWithAccuracy([s ENUToEFSpaceTransform], ARTransform3DLookAtRelative(ARPoint3DMake(ARWGS84SemiMajorAxis, 0., 0.), ARPoint3DMake(1., 0., 0.), ARPoint3DMake(0., 0., 1.), ARPoint3DZero), 1e-6), nil);
	[s release];
}

#pragma mark ARSpatialStateTest

- (ARQuaternion)quaternionWithBearing:(double)bearing pitch:(double)pitch roll:(double)roll {
	ARQuaternion q = ARQuaternionIdentity;
	q = ARQuaternionMultiply(ARQuaternionMakeWithCoordinates(sqrt(.5), sqrt(.5), 0., 0.), q);
	q = ARQuaternionMultiply(ARQuaternionMakeWithCoordinates(cos(roll / 2.), 0., -sin(roll / 2.), 0.), q);
	q = ARQuaternionMultiply(ARQuaternionMakeWithCoordinates(cos(pitch / 2.), sin(pitch / 2.), 0., 0.), q);
	q = ARQuaternionMultiply(ARQuaternionMakeWithCoordinates(cos(-bearing / 2.), 0., 0., sin(-bearing / 2.)), q);
	return q;
}

@end
