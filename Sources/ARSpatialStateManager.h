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
#import <QuartzCore/QuartzCore.h>
#import "ARPoint3D.h"


@class ARLocation;
@protocol ARSpatialStateManagerDelegate;


@interface ARSpatialStateManager : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate> {
@private
	id <ARSpatialStateManagerDelegate> delegate;
	BOOL delegateRespondsToLocationDidUpdate;

#if TARGET_IPHONE_SIMULATOR
	NSTimer *updateTimer;
#else
	CLLocationManager *locationManager;
#endif
	
	BOOL updating;
	UIAcceleration *rawAcceleration;
	CLLocation *rawLocation;
	CLHeading *rawHeading;
}

@property(nonatomic, assign) id <ARSpatialStateManagerDelegate> delegate;

@property(nonatomic, readonly, getter=isUpdating) BOOL updating;
@property(nonatomic, readonly, retain) UIAcceleration *rawAcceleration;
@property(nonatomic, readonly, retain) CLLocation *rawLocation;
@property(nonatomic, readonly, retain) CLHeading *rawHeading;

- (void)startUpdating;
- (void)stopUpdating;

- (ARLocation *)location;
- (ARPoint3D)locationAsECEFCoordinate;
- (CATransform3D)ENUToDeviceSpaceTransform;
- (CATransform3D)ECEFToENUSpaceTransform;
- (CATransform3D)ENUToECEFSpaceTransform;
- (CLLocationDistance)altitude;

@end


/**
 * Protocol that should be implemented by users of the ARSpatialStateManagerDelegate class.
 */
@protocol ARSpatialStateManagerDelegate <NSObject>

/**
 * Sent whenever the acceleration, location or heading has changed.
 * 
 * @param manager The sender of the message.
 */
- (void)spatialStateManagerDidUpdate:(ARSpatialStateManager *)manager;

@optional

/**
 * Sent in addition to spatialStateManagerDidUpdate: when the location has changed. This method will be called less often and therefore allows 
 */
- (void)spatialStateManagerLocationDidUpdate:(ARSpatialStateManager *)manager;

@end
