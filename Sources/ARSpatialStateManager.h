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

#import "ARPoint3D.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@protocol ARSpatialStateManagerDelegate;


@interface ARSpatialStateManager : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate> {
@private
	id <ARSpatialStateManagerDelegate> delegate;
	
	UIAccelerometer *accelerometer;
	CLLocationManager *locationManager;
	
	UIAcceleration *rawAcceleration;
	CLLocation *rawLocation;
	CLHeading *rawHeading;
}

@property(nonatomic, assign) id <ARSpatialStateManagerDelegate> delegate;

@property(nonatomic, readonly) UIAcceleration *rawAcceleration;
@property(nonatomic, readonly) CLLocation *rawLocation;
@property(nonatomic, readonly) CLHeading *rawHeading;

- (void)startUpdating;
- (void)stopUpdating;
- (ARPoint3D)positionInEcefCoordinates;
- (CATransform3D)enuToDeviceTransform;
- (CATransform3D)ecefToEnuTransform;

@end


/**
 * Protocol that should be implemented by users of the ARSpatialStateManagerDelegate class.
 */
@protocol ARSpatialStateManagerDelegate <NSObject>

/**
 * Sent whenever the acceleration, location, or heading changed.
 * 
 * @param manager the ARSpatialStateManager that sent this message
 */
- (void)spatialStateManagerDidUpdate:(ARSpatialStateManager *)manager;

@end