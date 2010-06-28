//
//  ARTransform3DTest.m
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

#import "ARTransform3DTest.h"
#import "ARTransform3D.h"


@implementation ARTransform3DTest

- (void)setUp {
}

- (void)testMakeFromAxesAndTranslation {
	static const ARTransform3D correctTransform = {
		1.1, 1.2, 1.3, 0.,
		2.1, 2.2, 2.3, 0.,
		3.1, 3.2, 3.3, 0.,
		4.1, 4.2, 4.3, 1.,
	};
	
	ARTransform3D testTransform = ARTransform3DMakeFromAxesAndTranslation(ARPoint3DMake(1.1, 1.2, 1.3), ARPoint3DMake(2.1, 2.2, 2.3), ARPoint3DMake(3.1, 3.2, 3.3), ARPoint3DMake(4.1, 4.2, 4.3));
	GHAssertTrue(CATransform3DEqualToTransform(testTransform, correctTransform), nil);
}

- (void)testMakeFromAxes {
	static const ARTransform3D correctTransform = {
		1.1, 1.2, 1.3, 0.,
		2.1, 2.2, 2.3, 0.,
		3.1, 3.2, 3.3, 0.,
		0.0, 0.0, 0.0, 1.,
	};
	
	ARTransform3D testTransform = ARTransform3DMakeFromAxes(ARPoint3DMake(1.1, 1.2, 1.3), ARPoint3DMake(2.1, 2.2, 2.3), ARPoint3DMake(3.1, 3.2, 3.3));
	GHAssertTrue(CATransform3DEqualToTransform(testTransform, correctTransform), nil);
}

- (void)testEqualsWithAccuracy {
	ARTransform3D original = { 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 };
	ARTransform3D copy = { 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 };
	GHAssertTrue(ARTransform3DEqualsWithAccuracy(original, original, 0.), nil);
	GHAssertTrue(ARTransform3DEqualsWithAccuracy(original, copy, 0.), nil);
	
	ARTransform3D valid[16] = {
		{ 1.100001, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.200001, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.300001, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.400001, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.100001, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.200001, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.300001, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.400001, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.099999, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.199999, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.299999, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.399999, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.099999, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.199999, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.299999, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.399999 },
	};
	for (int i = 0; i < 16; i++) {
		GHAssertTrue(ARTransform3DEqualsWithAccuracy(original, valid[i], 0.0000015), @"Should be equal for invalid[%d]", i);
	}
	
	ARTransform3D invalid[16] = {
		{ 1.100002, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.200002, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.300002, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.400002, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.100002, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.200002, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.300002, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.400002, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.099998, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.199998, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.299998, 3.4, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.399998, 4.1, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.099998, 4.2, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.199998, 4.3, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.299998, 4.4 },
		{ 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.399998 },
	};
	for (int i = 0; i < 16; i++) {
		GHAssertFalse(ARTransform3DEqualsWithAccuracy(original, invalid[i], 0.0000015), @"Should be unequal for invalid[%d]", i);
	}
}

- (void)testLookAt {
	GHAssertTrue(CATransform3DEqualToTransform(ARTransform3DLookAt(ARPoint3DZero, ARPoint3DMake(0., 0., 1.), ARPoint3DMake(0., 1., 0.), ARPoint3DZero), CATransform3DIdentity), nil);
	GHAssertTrue(CATransform3DEqualToTransform(ARTransform3DLookAt(ARPoint3DZero, ARPoint3DMake(0., 0., 1.), ARPoint3DMake(0., 0., 1.), ARPoint3DMake(0., 1., 0.)), CATransform3DIdentity), nil);
	
	ARTransform3D correctTransform = {
		sqrt(1./2.),  sqrt(1./2.),  0.,          0.,
		-sqrt(1./6.), sqrt(1./6.),  sqrt(2./3.), 0.,
		sqrt(1./3.),  -sqrt(1./3.), sqrt(1./3.), 0.,
		-10.5,        20.5,         30.5,        1.,
	};
	ARTransform3D testTransform = ARTransform3DLookAt(ARPoint3DMake(-10.5, 20.5, 30.5), ARPoint3DMake(-0.5, 10.5, 40.5), ARPoint3DMake(0., 0., 1.), ARPoint3DZero);
	GHAssertTrue(ARTransform3DEqualsWithAccuracy(testTransform, correctTransform, 0.000001), nil);
}

- (void)testTranspose {
	static const ARTransform3D transform = {
		1.1, 1.2, 1.3, 1.4,
		2.1, 2.2, 2.3, 2.4,
		3.1, 3.2, 3.3, 3.4,
		4.1, 4.2, 4.3, 4.4,
	};
	static const ARTransform3D transposedTransform = {
		1.1, 2.1, 3.1, 4.1,
		1.2, 2.2, 3.2, 4.2,
		1.3, 2.3, 3.3, 4.3,
		1.4, 2.4, 3.4, 4.4,
	};
	
	GHAssertTrue(CATransform3DEqualToTransform(ARTransform3DTranspose(transform), transposedTransform), nil);
	GHAssertTrue(CATransform3DEqualToTransform(ARTransform3DTranspose(transposedTransform), transform), nil);
}

- (void)testHomogeneousVectorMatrixMultipy {
	static const ARTransform3D transform = {
		1.1, 1.2, 1.3, 1.4,
		2.1, 2.2, 2.3, 2.4,
		3.1, 3.2, 3.3, 3.4,
		4.1, 4.2, 4.3, 4.4,
	};
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3DMake(0., 0., 0.), transform), ARPoint3DMake(4.1 / 4.4, 4.2 / 4.4, 4.3 / 4.4), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3DMake(1., 0., 0.), transform), ARPoint3DMake((4.1 + 1.1) / (4.4 + 1.4), (4.2 + 1.2) / (4.4 + 1.4), (4.3 + 1.3) / (4.4 + 1.4)), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3DMake(0., -2., 0.), transform), ARPoint3DMake((4.1 - 2. * 2.1) / (4.4 - 2. * 2.4), (4.2 - 2. * 2.2) / (4.4 - 2. * 2.4), (4.3 - 2. * 2.3) / (4.4 - 2. * 2.4)), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3DMake(0., 0., 3.), transform), ARPoint3DMake((4.1 + 3. * 3.1) / (4.4 + 3. * 3.4), (4.2 + 3. * 3.2) / (4.4 + 3. * 3.4), (4.3 + 3. * 3.3) / (4.4 + 3. * 3.4)), 1e-6), nil);
}

- (void)testNonhomogeneousVectorMatrixMultipy {
	static const ARTransform3D transform = {
		1.1, 1.2, 1.3, 1.4,
		2.1, 2.2, 2.3, 2.4,
		3.1, 3.2, 3.3, 3.4,
		4.1, 4.2, 4.3, 4.4,
	};
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARTransform3DNonhomogeneousVectorMatrixMultiply(ARPoint3DMake(0., 0., 0.), transform), ARPoint3DMake(0., 0., 0.), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARTransform3DNonhomogeneousVectorMatrixMultiply(ARPoint3DMake(1., 0., 0.), transform), ARPoint3DMake(1.1, 1.2, 1.3), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARTransform3DNonhomogeneousVectorMatrixMultiply(ARPoint3DMake(0., -2., 0.), transform), ARPoint3DMake(-2.*2.1, -2.*2.2, -2.*2.3), 1e-6), nil);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(ARTransform3DNonhomogeneousVectorMatrixMultiply(ARPoint3DMake(0., 0., 3.), transform), ARPoint3DMake(3.*3.1, 3.*3.2, 3.*3.3), 1e-6), nil);
}

@end
