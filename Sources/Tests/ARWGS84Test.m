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


@implementation ARWGS84Test

#pragma mark GHTestCase

- (void)testGetECEF {
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARWGS84GetECEF(0, 0, 0), ARPoint3DMake(ARWGS84SemiMajorAxis, 0, 0), 0.5), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARWGS84GetECEF(0, 180, 0), ARPoint3DMake(-ARWGS84SemiMajorAxis, 0, 0), 0.5), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARWGS84GetECEF(90, 0, 0), ARPoint3DMake(0, 0, ARWGS84SemiMinorAxis), 0.5), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARWGS84GetECEF(-90, 0, 0), ARPoint3DMake(0, 0, -ARWGS84SemiMinorAxis), 0.5), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARWGS84GetECEF(0, 90, 0), ARPoint3DMake(0, ARWGS84SemiMajorAxis, 0), 0.5), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARWGS84GetECEF(0, -90, 0), ARPoint3DMake(0, -ARWGS84SemiMajorAxis, 0), 0.5), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARWGS84GetECEF(52.469397, 5.509644, 10.0), ARPoint3DMake(3875688., 373845., 5034799.), 0.5), nil);
}

@end
