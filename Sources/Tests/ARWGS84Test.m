//
//  ARWGS84Test.m
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

#import "ARWGS84Test.h"
#import "ARWGS84.h"


@interface ARWGS84Test ()

- (void)assertPoint3D:(ARPoint3D)a equals:(ARPoint3D)b withAccuracy:(double)accuracy;

@end


@implementation ARWGS84Test

#pragma mark GHTestCase

- (void)testGetECEF {
	[self assertPoint3D:ARWGS84GetECEF(0, 0, 0) equals:ARPoint3DCreate(ARWGS84SemiMajorAxis, 0, 0) withAccuracy:0.5];
	[self assertPoint3D:ARWGS84GetECEF(0, 180, 0) equals:ARPoint3DCreate(-ARWGS84SemiMajorAxis, 0, 0) withAccuracy:0.5];
	[self assertPoint3D:ARWGS84GetECEF(90, 0, 0) equals:ARPoint3DCreate(0, 0, ARWGS84SemiMinorAxis) withAccuracy:0.5];
	[self assertPoint3D:ARWGS84GetECEF(-90, 0, 0) equals:ARPoint3DCreate(0, 0, -ARWGS84SemiMinorAxis) withAccuracy:0.5];
	[self assertPoint3D:ARWGS84GetECEF(0, 90, 0) equals:ARPoint3DCreate(0, ARWGS84SemiMajorAxis, 0) withAccuracy:0.5];
	[self assertPoint3D:ARWGS84GetECEF(0, -90, 0) equals:ARPoint3DCreate(0, -ARWGS84SemiMajorAxis, 0) withAccuracy:0.5];
	[self assertPoint3D:ARWGS84GetECEF(52.469397, 5.509644, 10.0) equals:ARPoint3DCreate(3875688., 373845., 5034799.) withAccuracy:0.5];
	
	// Finally, assert that the assertion works
	GHAssertThrows([self assertPoint3D:ARWGS84GetECEF(0, 0, 0) equals:ARPoint3DCreate(ARWGS84SemiMajorAxis + 1., 0, 0) withAccuracy:0.5], nil);
}

#pragma mark ARWGS84Test

- (void)assertPoint3D:(ARPoint3D)a equals:(ARPoint3D)b withAccuracy:(double)accuracy {
	GHAssertEqualsWithAccuracy(a.x, b.x, accuracy, nil);
	GHAssertEqualsWithAccuracy(a.y, b.y, accuracy, nil);
	GHAssertEqualsWithAccuracy(a.z, b.z, accuracy, nil);
}

@end
