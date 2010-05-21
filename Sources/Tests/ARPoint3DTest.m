//
//  ARPoint3DTest.m
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

#import "ARPoint3DTest.h"
#import "ARPoint3D.h"

@implementation ARPoint3DTest

static const ARPoint3D xAxis = {1., 0., 0.};
static const ARPoint3D yAxis = {0., 1., 0.};
static const ARPoint3D zAxis = {0., 0., 1.};
static const ARPoint3D a = {2., -3., 5.};
static const ARPoint3D b = {.5, .5, .5};

- (void)setUp {
}

- (void)testCreate {
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCreate(2., -3., 5.), a), nil);
}

- (void)testEquals {
	GHAssertTrue(ARPoint3DEquals(xAxis, xAxis), nil);
	GHAssertFalse(ARPoint3DEquals(xAxis, yAxis), nil);
	
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCreate(2., -3., 5.), a), nil);
	GHAssertFalse(ARPoint3DEquals(ARPoint3DCreate(2.0000001, -3., 5.), a), nil);
	GHAssertFalse(ARPoint3DEquals(ARPoint3DCreate(2., -3.0000001, 5.), a), nil);
	GHAssertFalse(ARPoint3DEquals(ARPoint3DCreate(2., -3., 5.0000001), a), nil);
	
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCreate(0., -0., 0.), ARPoint3DCreate(-0., 0., -0.)), nil); // This case fails using a direct memcmp, but should succeed.
}

- (void)testSubtract {
	// TODO: Implement
}

- (void)testDotProduct {
	GHAssertEquals(ARPoint3DDotProduct(xAxis, xAxis), 1., nil);
	GHAssertEquals(ARPoint3DDotProduct(xAxis, yAxis), 0., nil);
	GHAssertEquals(ARPoint3DDotProduct(xAxis, zAxis), 0., nil);
	GHAssertEquals(ARPoint3DDotProduct(yAxis, xAxis), 0., nil);
	GHAssertEquals(ARPoint3DDotProduct(yAxis, yAxis), 1., nil);
	GHAssertEquals(ARPoint3DDotProduct(yAxis, zAxis), 0., nil);
	GHAssertEquals(ARPoint3DDotProduct(zAxis, xAxis), 0., nil);
	GHAssertEquals(ARPoint3DDotProduct(zAxis, yAxis), 0., nil);
	GHAssertEquals(ARPoint3DDotProduct(zAxis, zAxis), 1., nil);
	
	GHAssertEquals(ARPoint3DDotProduct(a, xAxis), 2., nil);
	GHAssertEquals(ARPoint3DDotProduct(a, yAxis), -3., nil);
	GHAssertEquals(ARPoint3DDotProduct(a, zAxis), 5., nil);
}

- (void)testCrossProduct {
	// Note that this is risky due to precision; but it seems to work well.
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCrossProduct(xAxis, xAxis), ARPoint3DCreate( 0.,  0.,  0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCrossProduct(xAxis, yAxis), ARPoint3DCreate( 0.,  0.,  1.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCrossProduct(xAxis, zAxis), ARPoint3DCreate( 0., -1.,  0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCrossProduct(yAxis, xAxis), ARPoint3DCreate( 0.,  0., -1.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCrossProduct(yAxis, yAxis), ARPoint3DCreate( 0.,  0.,  0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCrossProduct(yAxis, zAxis), ARPoint3DCreate( 1.,  0.,  0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCrossProduct(zAxis, xAxis), ARPoint3DCreate( 0.,  1.,  0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCrossProduct(zAxis, yAxis), ARPoint3DCreate(-1.,  0.,  0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCrossProduct(zAxis, zAxis), ARPoint3DCreate( 0.,  0.,  0.)), nil);
	
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCrossProduct(b, zAxis), ARPoint3DCreate( .5, -.5, 0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DCrossProduct(zAxis, b), ARPoint3DCreate(-.5,  .5, 0.)), nil);
}

- (void)testLength {
	// Note that this is risky due to precision; but it seems to work well.
	GHAssertEquals(ARPoint3DLength(xAxis), 1., nil);
	GHAssertEquals(ARPoint3DLength(yAxis), 1., nil);
	GHAssertEquals(ARPoint3DLength(zAxis), 1., nil);
	
	GHAssertEquals(ARPoint3DLength(a), sqrt(38.), nil);
	GHAssertEquals(ARPoint3DLength(b), sqrt(3./4.), nil);
}

- (void)testScale {
	// Note that this is risky due to precision; but it seems to work well.
	GHAssertTrue(ARPoint3DEquals(ARPoint3DScale(xAxis, 2.), ARPoint3DCreate(2., 0., 0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DScale(yAxis, 3.), ARPoint3DCreate(0., 3., 0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DScale(zAxis, -4.), ARPoint3DCreate(0., 0., -4.)), nil);
	
	GHAssertTrue(ARPoint3DEquals(ARPoint3DScale(a, .5), ARPoint3DCreate(1., -1.5, 2.5)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DScale(b, 0.), ARPoint3DCreate(0., 0., 0.)), nil);
}

- (void)testNormalize {
	// Note that this is risky due to precision; but it seems to work well.
	GHAssertTrue(ARPoint3DEquals(ARPoint3DScale(xAxis, 2.), ARPoint3DCreate(2., 0., 0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DScale(yAxis, 3.), ARPoint3DCreate(0., 3., 0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DScale(zAxis, -4.), ARPoint3DCreate(0., 0., -4.)), nil);
	
	GHAssertTrue(ARPoint3DEquals(ARPoint3DScale(a, .5), ARPoint3DCreate(1., -1.5, 2.5)), nil);
	GHAssertTrue(ARPoint3DEquals(ARPoint3DScale(b, 0.), ARPoint3DCreate(0., 0., 0.)), nil);
}

@end
