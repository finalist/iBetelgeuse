//
//  ARCameraTest.m
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

#import "ARCameraTest.h"
#import "ARCamera.h"
#import "ARTransform3D.h"


@implementation ARCameraTest

#pragma mark GHTestCase

- (void)testInit {
	GHAssertThrows([[[ARCamera alloc] init] release], nil);
} 

- (void)testInitWithValuesAndProperties {
	GHAssertThrows([[[ARCamera alloc] initWithFocalLength:0 imagePlaneSize:CGSizeMake(1, 1) physical:NO] release], nil);
	GHAssertThrows([[[ARCamera alloc] initWithFocalLength:1 imagePlaneSize:CGSizeMake(0, 1) physical:NO] release], nil);
	GHAssertThrows([[[ARCamera alloc] initWithFocalLength:1 imagePlaneSize:CGSizeMake(1, 0) physical:NO] release], nil);
	
	GHAssertThrows([[[ARCamera alloc] initWithFocalLength:-1 imagePlaneSize:CGSizeMake(1, 1) physical:NO] release], nil);
	GHAssertThrows([[[ARCamera alloc] initWithFocalLength:1 imagePlaneSize:CGSizeMake(-1, 1) physical:NO] release], nil);
	GHAssertThrows([[[ARCamera alloc] initWithFocalLength:1 imagePlaneSize:CGSizeMake(1, -1) physical:NO] release], nil);
	
	ARCamera *camera = [[ARCamera alloc] initWithFocalLength:1 imagePlaneSize:CGSizeMake(2, 2) physical:YES];
	GHAssertTrue([camera isPhysical], nil);
	GHAssertEquals([camera focalLength], (CGFloat)1, nil);
	GHAssertTrue(CGSizeEqualToSize([camera imagePlaneSize], CGSizeMake(2, 2)), nil);
	GHAssertEquals([camera distanceToViewPlane], (CGFloat)1, nil);
	GHAssertEqualsWithAccuracy([camera angleOfView], (CGFloat)(M_PI / 2.), 1e-6, nil);
	GHAssertTrue(ARPoint3DEquals(ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3DMake(1.0, 1.0, 2.0), [camera perspectiveTransform]), ARPoint3DMake(-0.5, -0.5, -1.0)), nil);
	[camera release];
	
	camera = [[ARCamera alloc] initWithFocalLength:1 imagePlaneSize:CGSizeMake(2, 2) physical:NO];
	GHAssertFalse([camera isPhysical], nil);
	[camera release];
}

@end
