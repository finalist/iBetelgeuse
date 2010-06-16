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
#import "AROrientationFilter.h"
#import "ARAccelerometerFilter.h"


#define ACCELEROMETER_UPDATE_FREQUENCY 30 // Hz
#define LOCATION_EXPIRATION 60 // seconds
#define UP_DIRECTION_EXPIRATION 1 // seconds
#define NORTH_DIRECTION_EXPIRATION 1 // seconds


@interface ARSpatialStateManager () <UIAccelerometerDelegate, CLLocationManagerDelegate>

@property(nonatomic, readwrite, getter=isUpdating) BOOL updating;

#if TARGET_IPHONE_SIMULATOR
- (void)updateForSimulation;
#endif

- (void)updateOrientation;
- (void)updateWithRawLatitude:(CLLocationDegrees)rawLatitude longitude:(CLLocationDegrees)rawLongitude altitude:(CLLocationDistance)rawAltitude;
- (void)updateWithRawUpDirection:(ARPoint3D)rawUpDirection;
- (void)updateWithRawNorthDirection:(ARPoint3D)rawNorthDirection declination:(CGFloat)declination;

- (void)invalidateSpatialState;

@end


@interface ARSpatialState ()

- (id)initWithLocationAvailable:(BOOL)locationAvailable
						 recent:(BOOL)locationRecent
					   latitude:(CLLocationDegrees)latitude
					  longitude:(CLLocationDegrees)longitude
					   altitude:(CLLocationDistance)altitude
		   orientationAvailable:(BOOL)orientationAvailable
						 recent:(BOOL)isOrientationRecent
	 ENUToDeviceSpaceQuaternion:(ARQuaternion)anENUToDeviceSpaceQuaternion
			EFToECEFSpaceOffset:(ARPoint3D)EFToECEFSpaceOffset
					  timestamp:(NSDate *)timestamp;

@end


@implementation ARSpatialStateManager

@synthesize delegate, EFToECEFSpaceOffset;
@synthesize updating;

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		upDirectionFilter = [[ARAccelerometerFilter alloc] init];
		orientationFilter = [[AROrientationFilter alloc] init];
	}
	return self;
}

- (void)dealloc {
#if TARGET_IPHONE_SIMULATOR
	[updateTimer invalidate];
	[updateTimer release];
#else
	[locationManager release];
#endif

	[upDirectionFilter release];
	[orientationFilter release];
	[timestamp release];
	[spatialState release];
	
	[super dealloc];
}

#if !TARGET_IPHONE_SIMULATOR

#pragma mark UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)rawAcceleration {
	ARPoint3D rawUpDirection;
	rawUpDirection.x = -[rawAcceleration x];
	rawUpDirection.y = -[rawAcceleration y];
	rawUpDirection.z = -[rawAcceleration z];
	[self updateWithRawUpDirection:rawUpDirection];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newRawHeading {
	// Ignore invalid headings
	if (signbit([newRawHeading headingAccuracy])) {
		return;
	}
	
	ARPoint3D rawNorthDirection;
	rawNorthDirection.x = [newRawHeading x];
	rawNorthDirection.y = [newRawHeading y];
	rawNorthDirection.z = [newRawHeading z];

	// Determine compass declination in [-2pi, 2pi] at the current location as determined by the iPhone OS
	CGFloat rawDeclination = ([newRawHeading trueHeading] - [newRawHeading magneticHeading]) / 180.f * M_PI;
	
	[self updateWithRawNorthDirection:rawNorthDirection declination:rawDeclination];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newRawLocation fromLocation:(CLLocation *)previousRawLocation {
	// Ignore invalid or old locations
	if (signbit([newRawLocation horizontalAccuracy]) || [[newRawLocation timestamp] timeIntervalSinceNow] < -LOCATION_EXPIRATION) {
		return;
	}
	
	DebugLog(@"Got location location fix: %@", newRawLocation);
	
	[self updateWithRawLatitude:[newRawLocation coordinate].latitude longitude:[newRawLocation coordinate].longitude altitude:[newRawLocation altitude]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if ([error code] == kCLErrorDenied) {
		[locationManager stopUpdatingLocation];
	}
	else if ([error code] == kCLErrorHeadingFailure) {
		DebugLog(@"Heading failure");
	}
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

#endif

#pragma mark ARSpatialStateManager

- (void)setDelegate:(id <ARSpatialStateManagerDelegate>)aDelegate {
	delegate = aDelegate;
	
	// Determine whether the delegate implements this method, so that we don't have to check this a gazillion times a second
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	
	[updateTimer invalidate];
	updateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateTimerDidFire) userInfo:nil repeats:YES] retain];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
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
- (void)statusBarOrientationDidChange:(UIDevice *)device {
	[self updateForSimulation];
}

- (void)updateTimerDidFire {
	[self updateForSimulation];
}

- (void)updateForSimulation {
	static CGFloat simulatedLatitude = 0.0;
	[self updateWithRawLatitude:simulatedLatitude longitude:0 altitude:0];
	//	simulatedLatitude += 0.00005;
	
	// Assume the device is being held with the home button at the bottom
	static CGFloat simulatedUpAngle = 0.0;
	switch ([[UIApplication sharedApplication] statusBarOrientation]) {
		case UIInterfaceOrientationPortrait:
			[self updateWithRawUpDirection:ARPoint3DCreate(0, cosf(simulatedUpAngle), -sinf(simulatedUpAngle))];
			break;
			
		case UIInterfaceOrientationLandscapeRight:
			[self updateWithRawUpDirection:ARPoint3DCreate(cosf(simulatedUpAngle), 0, -sinf(simulatedUpAngle))];
			break;
			
		case UIInterfaceOrientationPortraitUpsideDown:
			[self updateWithRawUpDirection:ARPoint3DCreate(0, -cosf(simulatedUpAngle), -sinf(simulatedUpAngle))];
			break;
			
		case UIInterfaceOrientationLandscapeLeft:
			[self updateWithRawUpDirection:ARPoint3DCreate(-cosf(simulatedUpAngle), 0, -sinf(simulatedUpAngle))];
			break;
	}
	// simulatedUpAngle += .5f / 180.f * M_PI;
	
	// Assume the back of the device is pointing towards the north with a declination of -10º
	static CGFloat simulatedNorthAngle = 0.0;
	CGFloat declination = -10.f / 180.f * M_PI;
	switch ([[UIApplication sharedApplication] statusBarOrientation]) {
		case UIInterfaceOrientationPortrait:
			[self updateWithRawNorthDirection:ARPoint3DCreate(sinf(declination - simulatedNorthAngle), 0, -cosf(declination - simulatedNorthAngle)) declination:declination];
			break;
			
		case UIInterfaceOrientationLandscapeRight:
			[self updateWithRawNorthDirection:ARPoint3DCreate(0, -sinf(declination - simulatedNorthAngle), -cosf(declination - simulatedNorthAngle)) declination:declination];
			break;
			
		case UIInterfaceOrientationPortraitUpsideDown:
			[self updateWithRawNorthDirection:ARPoint3DCreate(-sinf(declination - simulatedNorthAngle), 0, -cosf(declination - simulatedNorthAngle)) declination:declination];
			break;
			
		case UIInterfaceOrientationLandscapeLeft:
			[self updateWithRawNorthDirection:ARPoint3DCreate(0, sinf(declination - simulatedNorthAngle), -cosf(declination - simulatedNorthAngle)) declination:declination];
			break;
	}
	//	simulatedNorthAngle += 10.f / 180.f * M_PI;
}
#endif

- (void)updateOrientation {
	// The ENU coordinate space is defined in device coordinate space by looking:
	// * from the device, which is at [0 0 0] in device coordinates;
	// * towards the sky, which is given by the up vector; and
	// * oriented towards the North pole, which is given by the north vector.
	if (upDirectionAvailable && northDirectionAvailable) {
		ARTransform3D ENUToDeviceSpaceTransform = ARTransform3DLookAtRelative(ARPoint3DZero, lastUpDirectionInDeviceSpace, lastNorthDirectionInDeviceSpace, ARPoint3DZero);
		ENUToDeviceSpaceQuaternion = [orientationFilter filterWithInput:ARQuaternionMakeWithTransform(ENUToDeviceSpaceTransform) timestamp:[NSDate timeIntervalSinceReferenceDate]];
	}
	
	[self invalidateSpatialState];
	
	[delegate spatialStateManagerDidUpdate:self];
}

- (void)updateWithRawLatitude:(CLLocationDegrees)rawLatitude longitude:(CLLocationDegrees)rawLongitude altitude:(CLLocationDistance)rawAltitude {
	locationAvailable = YES;
	locationTimeIntervalSinceReferenceDate = [NSDate timeIntervalSinceReferenceDate];
	
	latitude = rawLatitude;
	longitude = rawLongitude;
	altitude = rawAltitude;
	
	[self invalidateSpatialState];
	
	if (delegateRespondsToLocationDidUpdate) {
		[delegate spatialStateManagerLocationDidUpdate:self];
	}
	[delegate spatialStateManagerDidUpdate:self];
}

- (void)updateWithRawUpDirection:(ARPoint3D)rawUpDirection {
	upDirectionAvailable = YES;
	upDirectionTimeIntervalSinceReferenceDate = [NSDate timeIntervalSinceReferenceDate];
	lastUpDirectionInDeviceSpace = [upDirectionFilter filterWithInput:rawUpDirection timestamp:upDirectionTimeIntervalSinceReferenceDate];

	[self updateOrientation];
}

- (void)updateWithRawNorthDirection:(ARPoint3D)rawNorthDirection declination:(CGFloat)declination {
	// If we have an up direction, correct for magnetic declination
	if (upDirectionAvailable) {
		ARTransform3D declinationCorrectionTransform = CATransform3DMakeRotation(declination, lastUpDirectionInDeviceSpace.x, lastUpDirectionInDeviceSpace.y, lastUpDirectionInDeviceSpace.z);
		rawNorthDirection = ARTransform3DNonhomogeneousVectorMatrixMultiply(rawNorthDirection, declinationCorrectionTransform);
	}
	
	northDirectionAvailable = YES;
	northDirectionTimeIntervalSinceReferenceDate = [NSDate timeIntervalSinceReferenceDate];
	lastNorthDirectionInDeviceSpace = rawNorthDirection;

	[self updateOrientation];
}

- (ARSpatialState *)spatialState {
	if (spatialState == nil) {
		NSTimeInterval timeIntervalSinceReferenceDate = [NSDate timeIntervalSinceReferenceDate];
		BOOL locationRecent = (timeIntervalSinceReferenceDate - locationTimeIntervalSinceReferenceDate) <= LOCATION_EXPIRATION;
		BOOL upDirectionRecent = (timeIntervalSinceReferenceDate - upDirectionTimeIntervalSinceReferenceDate) <= UP_DIRECTION_EXPIRATION;
		BOOL northDirectionRecent = (timeIntervalSinceReferenceDate - northDirectionTimeIntervalSinceReferenceDate) <= NORTH_DIRECTION_EXPIRATION;
		
		spatialState = [[ARSpatialState alloc] initWithLocationAvailable:locationAvailable 
																  recent:locationRecent 
																latitude:latitude 
															   longitude:longitude 
																altitude:altitude 
													orientationAvailable:(upDirectionAvailable && northDirectionAvailable) 
																  recent:(upDirectionRecent && northDirectionRecent) 
											  ENUToDeviceSpaceQuaternion:ENUToDeviceSpaceQuaternion
													 EFToECEFSpaceOffset:EFToECEFSpaceOffset 
															   timestamp:timestamp];
	}
	return spatialState;
}

- (void)invalidateSpatialState {
	[timestamp release];
	timestamp = [[NSDate alloc] init];
	
	[spatialState release];
	spatialState = nil;
}

@end


@implementation ARSpatialState

#pragma mark NSObject

- (id)initWithLocationAvailable:(BOOL)isLocationAvailable 
						 recent:(BOOL)isLocationRecent 
					   latitude:(CLLocationDegrees)aLatitude 
					  longitude:(CLLocationDegrees)aLongitude
					   altitude:(CLLocationDistance)anAltitude 
		   orientationAvailable:(BOOL)isOrientationAvailable 
						 recent:(BOOL)isOrientationRecent 
	 ENUToDeviceSpaceQuaternion:(ARQuaternion)anENUToDeviceSpaceQuaternion
			EFToECEFSpaceOffset:(ARPoint3D)anEFToECEFSpaceOffset 
					  timestamp:(NSDate *)aTimestamp {
	if (self = [super init]) {
		flags.locationAvailable = isLocationAvailable;
		flags.locationRecent = isLocationRecent;
		flags.orientationAvailable = isOrientationAvailable;
		flags.orientationRecent = isOrientationRecent;
		latitude = aLatitude;
		longitude = aLongitude;
		altitude = anAltitude;
		ENUToDeviceSpaceQuaternion = anENUToDeviceSpaceQuaternion;
		EFToECEFSpaceOffset = anEFToECEFSpaceOffset;
		timestamp = [aTimestamp retain];
	}
	return self;
}

- (void)dealloc {
	[timestamp release];
	[location release];
	
	[super dealloc];
}

#pragma mark ARSpatialState

- (BOOL)isLocationAvailable {
	return flags.locationAvailable;
}

- (BOOL)isLocationRecent {
	return flags.locationRecent;
}

- (BOOL)isOrientationAvailable {
	return flags.orientationAvailable;
}

- (BOOL)isOrientationRecent {
	return flags.orientationRecent;
}

@synthesize timestamp;

- (ARLocation *)location {
	if ([self isLocationAvailable]) {
		if (location == nil) {
			location = [[ARLocation alloc] initWithLatitude:latitude longitude:longitude altitude:altitude];
		}
		return location;
	}
	else {
		return nil;
	}
}

@synthesize altitude;

- (ARPoint3D)locationInECEFSpace {
	if (!flags.haveLocationInECEFSpace) {
		locationInECEFSpace = ARWGS84GetECEF(latitude, longitude, altitude);
		flags.haveLocationInECEFSpace = YES;
	}
	return locationInECEFSpace;
}

- (ARPoint3D)locationInEFSpace {
	return ARPoint3DSubtract([self locationInECEFSpace], [self EFToECEFSpaceOffset]);
}

- (ARPoint3D)upDirectionInENUSpace {
	return ARPoint3DCreate(0., 0., 1.); // By definition
}

- (ARPoint3D)upDirectionInDeviceSpace {
	if (!flags.haveUpDirectionInDeviceSpace) {
		if ([self isOrientationAvailable]) {
			upDirectionInDeviceSpace = ARTransform3DHomogeneousVectorMatrixMultiply([self upDirectionInENUSpace], [self ENUToDeviceSpaceTransform]);
		} else {
			upDirectionInDeviceSpace = [self upDirectionInENUSpace];
		}
		flags.haveUpDirectionInDeviceSpace = true;
	}
	return upDirectionInDeviceSpace;
}

- (ARPoint3D)upDirectionInECEFSpace {
	return [self locationInECEFSpace];
}

- (ARPoint3D)upDirectionInEFSpace {
	return [self upDirectionInECEFSpace];
}

- (ARPoint3D)northDirectionInENUSpace {
	return ARPoint3DCreate(0., 1., 0.); // By definition; alongst the horizontal plane. TODO: Document that the northDirectionIn...Space methods do -not- return the same vector if transformed back to the same space.
}

- (ARPoint3D)northDirectionInDeviceSpace {
	if (!flags.haveNorthDirectionInDeviceSpace) {
		if ([self isOrientationAvailable]) {
			northDirectionInDeviceSpace = ARTransform3DHomogeneousVectorMatrixMultiply([self northDirectionInENUSpace], [self ENUToDeviceSpaceTransform]);
		} else {
			northDirectionInDeviceSpace = [self northDirectionInENUSpace];
		}
		flags.haveNorthDirectionInDeviceSpace = true;
	}
	return northDirectionInDeviceSpace;
}

- (ARPoint3D)northDirectionInECEFSpace {
	// By definition of ECEF, the North pole is located along the z-axis
	return ARPoint3DCreate(0., 0., 1.);
}

- (ARPoint3D)northDirectionInEFSpace {
	// By definition of ECEF, the North pole is located along the z-axis
	return [self northDirectionInECEFSpace];
}

- (CATransform3D)ENUToDeviceSpaceTransform {
	if (!flags.haveENUToDeviceSpaceTransform) {
		if ([self isOrientationAvailable]) {
			ENUToDeviceSpaceTransform = ARQuaternionConvertToMatrix(ENUToDeviceSpaceQuaternion);
		}
		else {
			ENUToDeviceSpaceTransform = CATransform3DIdentity;
		}
		flags.haveENUToDeviceSpaceTransform = YES;
	}
	return ENUToDeviceSpaceTransform;
}

- (CATransform3D)DeviceToENUSpaceTransform {
	if (!flags.haveDeviceToENUSpaceTransform) {
		// Since we're dealing with orthogonal matrices, transposing is the same as inverting (but then easier)
		DeviceToENUSpaceTransform = ARTransform3DTranspose([self ENUToDeviceSpaceTransform]);
		flags.haveDeviceToENUSpaceTransform = YES;
	}
	return DeviceToENUSpaceTransform;
}

- (CATransform3D)ENUToEFSpaceTransform {
	if (!flags.haveENUToEFSpaceTransform) {
		if ([self isLocationAvailable] && [self isOrientationAvailable]) {
			// The ENU coordinate space is defined in ECEF coordinate space by looking:
			// * from the device, which is given by the GPS after conversion to ECEF;
			// * towards the sky, which is the same vector as the ECEF position since the ECEF origin is defined to be at the Earth's center; and
			// * oriented towards the North pole, which is defined to be the z-axis of the ECEF coordinate system.
			ENUToEFSpaceTransform = ARTransform3DLookAtRelative([self locationInEFSpace], [self upDirectionInEFSpace], [self northDirectionInEFSpace], ARPoint3DZero);
		}
		else {
			ENUToEFSpaceTransform = CATransform3DIdentity;
		}
		flags.haveENUToEFSpaceTransform = YES;
	}
	return ENUToEFSpaceTransform;
}

- (CATransform3D)EFToENUSpaceTransform {
	if (!flags.haveEFToENUSpaceTransform) {
		// Since we're dealing with orthogonal matrices, transposing is the same as inverting (but then easier)
		EFToENUSpaceTransform = ARTransform3DTranspose([self ENUToEFSpaceTransform]);
		flags.haveEFToENUSpaceTransform = YES;
	}
	return EFToENUSpaceTransform;
}

@synthesize EFToECEFSpaceOffset;

@end
