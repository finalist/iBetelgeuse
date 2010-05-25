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
	
	ARTransform3D testTransform = ARTransform3DMakeFromAxesAndTranslation(ARPoint3DCreate(1.1, 1.2, 1.3), ARPoint3DCreate(2.1, 2.2, 2.3), ARPoint3DCreate(3.1, 3.2, 3.3), ARPoint3DCreate(4.1, 4.2, 4.3));
	GHAssertTrue(CATransform3DEqualToTransform(testTransform, correctTransform), nil);
}

- (void)testMakeFromAxes {
	static const ARTransform3D correctTransform = {
		1.1, 1.2, 1.3, 0.,
		2.1, 2.2, 2.3, 0.,
		3.1, 3.2, 3.3, 0.,
		0.0, 0.0, 0.0, 1.,
	};
	
	ARTransform3D testTransform = ARTransform3DMakeFromAxes(ARPoint3DCreate(1.1, 1.2, 1.3), ARPoint3DCreate(2.1, 2.2, 2.3), ARPoint3DCreate(3.1, 3.2, 3.3));
	GHAssertTrue(CATransform3DEqualToTransform(testTransform, correctTransform), nil);
}

- (void)testLookAt {
	GHAssertTrue(CATransform3DEqualToTransform(ARTransform3DLookAt(ARPoint3DZero, ARPoint3DCreate(0., 0., 1.), ARPoint3DCreate(0., 1., 0.), ARPoint3DZero), CATransform3DIdentity), nil);
	GHAssertTrue(CATransform3DEqualToTransform(ARTransform3DLookAt(ARPoint3DZero, ARPoint3DCreate(0., 0., 1.), ARPoint3DCreate(0., 0., 1.), ARPoint3DCreate(0., 1., 0.)), CATransform3DIdentity), nil);
	
	ARTransform3D correctTransform = {
		sqrt(1./2.),  sqrt(1./2.),  0.,          0.,
		-sqrt(1./6.), sqrt(1./6.),  sqrt(2./3.), 0.,
		sqrt(1./3.),  -sqrt(1./3.), sqrt(1./3.), 0.,
		-10.5,        20.5,         30.5,        1.,
	};
	ARTransform3D testTransform = ARTransform3DLookAt(ARPoint3DCreate(-10.5, 20.5, 30.5), ARPoint3DCreate(-0.5, 10.5, 40.5), ARPoint3DCreate(0., 0., 1.), ARPoint3DZero);
	GHAssertEqualsWithAccuracy(testTransform.m11, correctTransform.m11, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m12, correctTransform.m12, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m13, correctTransform.m13, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m14, correctTransform.m14, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m21, correctTransform.m21, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m22, correctTransform.m22, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m23, correctTransform.m23, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m24, correctTransform.m24, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m31, correctTransform.m31, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m32, correctTransform.m32, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m33, correctTransform.m33, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m34, correctTransform.m34, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m41, correctTransform.m41, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m42, correctTransform.m42, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m43, correctTransform.m43, 0.000001, nil);
	GHAssertEqualsWithAccuracy(testTransform.m44, correctTransform.m44, 0.000001, nil);
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
	GHAssertTrue(ARPoint3DEquals(ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3DCreate(0., 0., 0.), transform), ARPoint3DCreate(4.1, 4.2, 4.3)), nil);
	GHAssertTrue(ARPoint3DEquals(ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3DCreate(1., 0., 0.), transform), ARPoint3DCreate(4.1+1.1, 4.2+1.2, 4.3+1.3)), nil);
	GHAssertTrue(ARPoint3DEquals(ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3DCreate(0., -2., 0.), transform), ARPoint3DCreate(4.1-2.*2.1, 4.2-2.*2.2, 4.3-2.*2.3)), nil);
	GHAssertTrue(ARPoint3DEquals(ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3DCreate(0., 0., 3.), transform), ARPoint3DCreate(4.1+3.*3.1, 4.2+3.*3.2, 4.3+3.*3.3)), nil);
}

- (void)testNonhomogeneousVectorMatrixMultipy {
	static const ARTransform3D transform = {
		1.1, 1.2, 1.3, 1.4,
		2.1, 2.2, 2.3, 2.4,
		3.1, 3.2, 3.3, 3.4,
		4.1, 4.2, 4.3, 4.4,
	};
	GHAssertTrue(ARPoint3DEquals(ARTransform3DNonhomogeneousVectorMatrixMultiply(ARPoint3DCreate(0., 0., 0.), transform), ARPoint3DCreate(0., 0., 0.)), nil);
	GHAssertTrue(ARPoint3DEquals(ARTransform3DNonhomogeneousVectorMatrixMultiply(ARPoint3DCreate(1., 0., 0.), transform), ARPoint3DCreate(1.1, 1.2, 1.3)), nil);
	GHAssertTrue(ARPoint3DEquals(ARTransform3DNonhomogeneousVectorMatrixMultiply(ARPoint3DCreate(0., -2., 0.), transform), ARPoint3DCreate(-2.*2.1, -2.*2.2, -2.*2.3)), nil);
	GHAssertTrue(ARPoint3DEquals(ARTransform3DNonhomogeneousVectorMatrixMultiply(ARPoint3DCreate(0., 0., 3.), transform), ARPoint3DCreate(3.*3.1, 3.*3.2, 3.*3.3)), nil);
}

@end
