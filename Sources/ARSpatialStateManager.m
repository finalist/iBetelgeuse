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
#import "ARSpatialState.h"
#import "ARLocation.h"
#import "ARTransform3D.h"
#import "ARWGS84.h"
#import "AROrientationFilter.h"
#import "ARAccelerometerFilter.h"


// The frequency at which we like to get accelerometer updates
#define ACCELEROMETER_UPDATE_FREQUENCY 30 // Hz

// The maximum age of a location that we (a) consider a valid new measurement and (b) we deem a reliable old measurement
#define LOCATION_EXPIRATION 10 // seconds

// The maximum horizontal accuracy of a location that we consider at all
#define LOCATION_MINIMUM_HORIZONTAL_ACCURACY 1000 // meters

// The maximum age of an orientation measurement that we deem reliable
#define ORIENTATION_EXPIRATION 1 // seconds


#if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_DEVICE
@interface ARSpatialStateManager () <UIAccelerometerDelegate, CLLocationManagerDelegate>
#else
@interface ARSpatialStateManager ()
#endif

@property(nonatomic, readwrite, getter=isUpdating) BOOL updating;

#if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_SIMULATOR

/**
 * Updates the receiver with a fresh simulated set of measurements.
 */
- (void)updateForSimulation;

/**
 * Callback for the UIApplicationDidChangeStatusBarOrientationNotification to use the iPhone Simulator's rotation to simulate actual device rotation.
 */
- (void)statusBarOrientationDidChange;

/**
 * Callback for an NSTimer that runs a simulation.
 */
- (void)updateTimerDidFire;

#endif

/**
 * Updates the receiver's orientation (in particular, the ENU to device quaternion) using the most recently measured raw up and north directions.
 */
- (void)updateOrientation;

/**
 * Updates the receiver's location with the given raw location.
 *
 * @param rawLatitude The raw WGS84 latitude.
 * @param rawLongitude The raw WGS84 longitude.
 * @param rawAltitude The raw WGS84 altitude.
 * @param reliable A flag indicating whether the given location information should be considered reliable (at discretion of the caller).
 */
- (void)updateWithRawLatitude:(CLLocationDegrees)rawLatitude longitude:(CLLocationDegrees)rawLongitude altitude:(CLLocationDistance)rawAltitude reliable:(BOOL)reliable;

/**
 * Updates the receiver's orientation with the given raw up direction.
 *
 * @param rawUpDirection The raw up direction vector in device space.
 */
- (void)updateWithRawUpDirection:(ARPoint3D)rawUpDirection;

/**
 * Updates the receiver's orientation with the given raw North direction.
 *
 * @param rawUpDirection The raw North direction vector in device space.
 * @param declination The raw declination between true and magnetic North in radians.
 */
- (void)updateWithRawNorthDirection:(ARPoint3D)rawNorthDirection declination:(CGFloat)declination;

/**
 * Invalidates the spatial state of the receiver, optionally resetting the timestamp of the spatial state to the current time. When someone requests the spatial state following this method, a new spatial state object will be constructed.
 *
 * @param resetTimestamp Whether the timestamp of the spatial state should be reset to the current time. Should be YES if and only if new measurements were done to the location or the orientation.
 */
- (void)invalidateSpatialStateResettingTimestamp:(BOOL)resetTimestamp;

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
#if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_SIMULATOR
	[updateTimer invalidate];
	[updateTimer release];
#else if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_DEVICE
	[locationManager release];
#endif

	[upDirectionFilter release];
	[orientationFilter release];
	
	[timestamp release];
	[spatialState release];
	
	[super dealloc];
}

#if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_DEVICE

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
	if (signbit([newRawLocation horizontalAccuracy]) || [[newRawLocation timestamp] timeIntervalSinceNow] < -LOCATION_EXPIRATION || [newRawLocation horizontalAccuracy] > LOCATION_MINIMUM_HORIZONTAL_ACCURACY) {
		return;
	}
	
	DebugLog(@"Got location location fix: %@", newRawLocation);
	//DebugLog(@"%f %f", [newRawLocation altitude], [newRawLocation verticalAccuracy]);
	
	// Note: when verticalAccuracy < 0 we probably don't have a GPS fix
	[self updateWithRawLatitude:[newRawLocation coordinate].latitude longitude:[newRawLocation coordinate].longitude altitude:[newRawLocation altitude] reliable:[newRawLocation verticalAccuracy] >= 0];
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

- (void)setEFToECEFSpaceOffset:(ARPoint3D)anOffset {
	EFToECEFSpaceOffset = anOffset;
	
	// Invalidate the spatial state, but don't reset the timestamp since no actual measurements have changed
	[self invalidateSpatialStateResettingTimestamp:NO];
}

- (void)startUpdating {
	if ([self isUpdating]) {
		return;
	}
	else {
		[self setUpdating:YES];
	}

#if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_SIMULATOR
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	
	[updateTimer invalidate];
	updateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateTimerDidFire) userInfo:nil repeats:YES] retain];
#else if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_DEVICE
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	[accelerometer setDelegate:self];
	[accelerometer setUpdateInterval:1. / ACCELEROMETER_UPDATE_FREQUENCY];

	[locationManager release];
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDelegate:self];
	[locationManager setDistanceFilter:kCLDistanceFilterNone];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	
	// We don't check the locationServicesEnabled property, the user should know that this application wants to know his/her location
	[locationManager startUpdatingLocation];
	
	if ([locationManager headingAvailable]) {
		[locationManager startUpdatingHeading];
	}
#endif
}

- (void)stopUpdating {
	if (![self isUpdating]) {
		return;
	}
	
#if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_SIMULATOR
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[updateTimer invalidate];
	[updateTimer release];
	updateTimer = nil;
#else if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_DEVICE
	// Make sure the accelerometer stops calling us
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	if ([accelerometer delegate] == self) {
		[accelerometer setDelegate:nil];
	}
	else {
		DebugLog(@"Warning: the accelerometer delegate was inadvertedly changed by another object");
	}

	[locationManager stopUpdatingLocation];
	[locationManager stopUpdatingHeading];
	[locationManager release];
	locationManager = nil;
#endif
	
	[self setUpdating:NO];
}

#if SPATIAL_STATE_MANAGER_MODE == SPATIAL_STATE_MANAGER_MODE_SIMULATOR
- (void)statusBarOrientationDidChange {
	[self updateForSimulation];
}

- (void)updateTimerDidFire {
	[self updateForSimulation];
}

- (void)updateForSimulation {
	static CGFloat simulatedLatitude = 0.0;
	[self updateWithRawLatitude:simulatedLatitude longitude:0 altitude:0 reliable:YES];
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
	 simulatedUpAngle += .5f / 180.f * M_PI;
	
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
		orientationAvailable = YES;
		orientationTimeIntervalSinceReferenceDate = [NSDate timeIntervalSinceReferenceDate];
		
		ARTransform3D ENUToDeviceSpaceTransform = ARTransform3DLookAtRelative(ARPoint3DZero, lastUpDirectionInDeviceSpace, lastNorthDirectionInDeviceSpace, ARPoint3DZero);
		ENUToDeviceSpaceQuaternion = [orientationFilter filterWithInput:ARQuaternionMakeWithTransform(ENUToDeviceSpaceTransform) timestamp:orientationTimeIntervalSinceReferenceDate];

		[self invalidateSpatialStateResettingTimestamp:YES];
		
		[delegate spatialStateManagerDidUpdate:self];
	}
}

- (void)updateWithRawLatitude:(CLLocationDegrees)rawLatitude longitude:(CLLocationDegrees)rawLongitude altitude:(CLLocationDistance)rawAltitude reliable:(BOOL)reliable {
	locationAvailable = YES;
	locationReliable = reliable;
	locationTimeIntervalSinceReferenceDate = [NSDate timeIntervalSinceReferenceDate];
	
	latitude = rawLatitude;
	longitude = rawLongitude;
	altitude = rawAltitude;
	
	[self invalidateSpatialStateResettingTimestamp:YES];
	
	if (delegateRespondsToLocationDidUpdate) {
		[delegate spatialStateManagerLocationDidUpdate:self];
	}
	[delegate spatialStateManagerDidUpdate:self];
}

- (void)updateWithRawUpDirection:(ARPoint3D)rawUpDirection {
	upDirectionAvailable = YES;
	lastUpDirectionInDeviceSpace = [upDirectionFilter filterWithInput:rawUpDirection timestamp:[NSDate timeIntervalSinceReferenceDate]];

	[self updateOrientation];
}

- (void)updateWithRawNorthDirection:(ARPoint3D)rawNorthDirection declination:(CGFloat)declination {
	// If we have an up direction, correct for magnetic declination
	if (upDirectionAvailable) {
		ARTransform3D declinationCorrectionTransform = CATransform3DMakeRotation(declination, lastUpDirectionInDeviceSpace.x, lastUpDirectionInDeviceSpace.y, lastUpDirectionInDeviceSpace.z);
		rawNorthDirection = ARTransform3DNonhomogeneousVectorMatrixMultiply(rawNorthDirection, declinationCorrectionTransform);
	}
	
	northDirectionAvailable = YES;
	lastNorthDirectionInDeviceSpace = rawNorthDirection;

	[self updateOrientation];
}

- (ARSpatialState *)spatialState {
	if (spatialState == nil) {
		NSTimeInterval timeIntervalSinceReferenceDate = [NSDate timeIntervalSinceReferenceDate];
		BOOL locationRecent = (timeIntervalSinceReferenceDate - locationTimeIntervalSinceReferenceDate) <= LOCATION_EXPIRATION;
		BOOL orientationRecent = (timeIntervalSinceReferenceDate - orientationTimeIntervalSinceReferenceDate) <= ORIENTATION_EXPIRATION;
		
		spatialState = [[ARSpatialState alloc] initWithLocationAvailable:locationAvailable
																reliable:(locationReliable && locationRecent)
																latitude:latitude
															   longitude:longitude
																altitude:altitude
													orientationAvailable:orientationAvailable
																reliable:orientationRecent
											  ENUToDeviceSpaceQuaternion:ENUToDeviceSpaceQuaternion
													 EFToECEFSpaceOffset:EFToECEFSpaceOffset
															   timestamp:timestamp];
	}
	return spatialState;
}

- (void)invalidateSpatialStateResettingTimestamp:(BOOL)resetTimestamp {
	if (resetTimestamp) {
		[timestamp release];
		timestamp = [[NSDate alloc] init];
	}
	
	[spatialState release];
	spatialState = nil;
}

@end
