//
//  ARQuaternionTest.m
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

#import "ARQuaternionTest.h"
#import "ARQuaternion.h"

@implementation ARQuaternionTest
- (void)setUp {
}

- (void)testMakeWithCoordinates {
	ARQuaternion correct = { 1.2, -2.3, 3.4, -4.5 };
	ARQuaternion testee = ARQuaternionMakeWithCoordinates(1.2, -2.3, 3.4, -4.5);
	GHAssertTrue(ARQuaternionEquals(testee, correct), nil);
}

- (void)testMakeWithPoint {
	ARQuaternion correct = { 0, -1.2, 2.3, -3.4 };
	ARQuaternion testee = ARQuaternionMakeWithPoint(ARPoint3DCreate(-1.2, 2.3, -3.4));
	GHAssertTrue(ARQuaternionEquals(testee, correct), nil);
}

- (void)testMakeWithTransform {
	{
		CATransform3D original = {
			-0.6508,  0.1256, -0.7488, 0,
			0.6860, -0.3254, -0.6508, 0,
			-0.3254, -0.9372,  0.1256, 0,
			0,       0,       0, 1
		};
		ARQuaternion correct = { 0.1933, -0.3705, -0.5477, 0.7249 };
		ARQuaternion testee = ARQuaternionMakeWithTransform(original);
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, .0001), nil);
	}
	
	{
		CATransform3D original = {
			-1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, -1, 0,
			0, 0, 0, 1
		};
		ARQuaternion correct = { 0, 0, 1, 0 };
		ARQuaternion testee = ARQuaternionMakeWithTransform(original);
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, .0001), nil);
	}
}

- (void)testNegate {
	ARQuaternion original = { 0.1, 1.2, -2.3, 3.4 };
	ARQuaternion conjugate = { -0.1, -1.2, 2.3, -3.4 };
	ARQuaternion testee1 = ARQuaternionNegate(original);
	ARQuaternion testee2 = ARQuaternionNegate(conjugate);
	GHAssertTrue(ARQuaternionEquals(testee1, conjugate), nil);
	GHAssertTrue(ARQuaternionEquals(testee2, original), nil);
}

- (void)testConjugate {
	ARQuaternion original = { 0.1, 1.2, -2.3, 3.4 };
	ARQuaternion conjugate = { 0.1, -1.2, 2.3, -3.4 };
	ARQuaternion testee1 = ARQuaternionConjugate(original);
	ARQuaternion testee2 = ARQuaternionConjugate(conjugate);
	GHAssertTrue(ARQuaternionEquals(testee1, conjugate), nil);
	GHAssertTrue(ARQuaternionEquals(testee2, original), nil);
}

- (void)testAdd {
	ARQuaternion original1 = { 0.1, 1.2, 2.3, -3.4 };
	ARQuaternion original2 = { 60, 70, 80, -90 };
	ARQuaternion correct = { 60.1, 71.2, 82.3, -93.4 };
	ARQuaternion testee = ARQuaternionAdd(original1, original2);
	GHAssertTrue(ARQuaternionEquals(testee, correct), nil);
}

- (void)testSubtract {
	ARQuaternion original1 = { 0.1, 1.2, 2.3, -3.4 };
	ARQuaternion original2 = { -60, -70, -80, 90 };
	ARQuaternion correct = { 60.1, 71.2, 82.3, -93.4 };
	ARQuaternion testee = ARQuaternionSubtract(original1, original2);
	GHAssertTrue(ARQuaternionEquals(testee, correct), nil);
}

- (void)testMultiply {
	ARQuaternion original1 = { .1, -20, 30, -40 };
	ARQuaternion original2 = { 1.2, -2.3, -3.4, 4.5 };
	ARQuaternion correct = { 236.1200, -25.2300, 217.6600, 89.4500 };
	ARQuaternion testee = ARQuaternionMultiply(original1, original2);
	GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, .0001), nil);
}

- (void)testMultiplyByScalar {
	ARQuaternion original1 = { 0.1, 1.2, 2.3, -3.4 };
	double original2 = -.5;
	ARQuaternion correct = { -.05, -.6, -1.15, 1.7 };
	ARQuaternion testee = ARQuaternionMultiplyByScalar(original1, original2);
	GHAssertTrue(ARQuaternionEquals(testee, correct), nil);
}

- (void)testElementsMaxAbs {
	ARQuaternion original = { 4.4, 4.4, 4.4, 4.4 };
	ARQuaternion maxW = { 4.5, 4.4, 4.4, 4.4 };
	ARQuaternion maxX = { 4.4, 4.5, 4.4, 4.4 };
	ARQuaternion maxY = { 4.4, 4.4, 4.5, 4.4 };
	ARQuaternion maxZ = { 4.4, 4.4, 4.4, 4.5 };
	GHAssertEquals(ARQuaternionElementsMaxAbs(original), 4.4, nil);
	GHAssertEquals(ARQuaternionElementsMaxAbs(maxW), 4.5, nil);
	GHAssertEquals(ARQuaternionElementsMaxAbs(maxX), 4.5, nil);
	GHAssertEquals(ARQuaternionElementsMaxAbs(maxY), 4.5, nil);
	GHAssertEquals(ARQuaternionElementsMaxAbs(maxZ), 4.5, nil);
}

- (void)testDotProduct {
	ARQuaternion original1 = { 0.1, 1.2, -2.3, -3.4 };
	ARQuaternion original2 = { 60, -70, 80, -90 };
	double correct = 44;
	double testee = ARQuaternionDotProduct(original1, original2);
	GHAssertEquals(testee, correct, nil);
}

- (void)testEquals {
	ARQuaternion original = { 1.2, 2.3, 3.4, 4.5 };
	ARQuaternion copy = { 1.2, 2.3, 3.4, 4.5 };
	ARQuaternion invalidW = { 1.200001, 2.3, 3.4, 4.5 };
	ARQuaternion invalidX = { 1.2, 2.299999, 3.4, 4.5 };
	ARQuaternion invalidY = { 1.2, 2.3, 3.400001, 4.5 };
	ARQuaternion invalidZ = { 1.2, 2.3, 3.4, 4.499999 };
	GHAssertTrue(ARQuaternionEquals(original, original), nil);
	GHAssertTrue(ARQuaternionEquals(original, copy), nil);
	GHAssertFalse(ARQuaternionEquals(original, invalidW), nil);
	GHAssertFalse(ARQuaternionEquals(original, invalidX), nil);
	GHAssertFalse(ARQuaternionEquals(original, invalidY), nil);
	GHAssertFalse(ARQuaternionEquals(original, invalidZ), nil);
}

- (void)testEqualsWithAccuracy {
	ARQuaternion original = { 1.2, 2.3, 3.4, 4.5 };
	ARQuaternion copy = { 1.2, 2.3, 3.4, 4.5 };
	ARQuaternion validW = { 1.200001, 2.3, 3.4, 4.5 };
	ARQuaternion validX = { 1.2, 2.299999, 3.4, 4.5 };
	ARQuaternion validY = { 1.2, 2.3, 3.400001, 4.5 };
	ARQuaternion validZ = { 1.2, 2.3, 3.4, 4.499999 };
	ARQuaternion invalidW = { 1.200002, 2.3, 3.4, 4.5 };
	ARQuaternion invalidX = { 1.2, 2.299998, 3.4, 4.5 };
	ARQuaternion invalidY = { 1.2, 2.3, 3.400002, 4.5 };
	ARQuaternion invalidZ = { 1.2, 2.3, 3.4, 4.499998 };
	GHAssertTrue(ARQuaternionEqualsWithAccuracy(original, original, 0.), nil);
	GHAssertTrue(ARQuaternionEqualsWithAccuracy(original, copy, 0.), nil);
	GHAssertTrue(ARQuaternionEqualsWithAccuracy(original, validW, 0.0000015), nil);
	GHAssertTrue(ARQuaternionEqualsWithAccuracy(original, validX, 0.0000015), nil);
	GHAssertTrue(ARQuaternionEqualsWithAccuracy(original, validY, 0.0000015), nil);
	GHAssertTrue(ARQuaternionEqualsWithAccuracy(original, validZ, 0.0000015), nil);
	GHAssertFalse(ARQuaternionEqualsWithAccuracy(original, invalidW, 0.0000015), nil);
	GHAssertFalse(ARQuaternionEqualsWithAccuracy(original, invalidX, 0.0000015), nil);
	GHAssertFalse(ARQuaternionEqualsWithAccuracy(original, invalidY, 0.0000015), nil);
	GHAssertFalse(ARQuaternionEqualsWithAccuracy(original, invalidZ, 0.0000015), nil);
}

- (void)testNorm {
	ARQuaternion original = { 1.2, 2.3, 3.4, 4.5 };
	double testee = ARQuaternionNorm(original);
	GHAssertEqualsWithAccuracy(testee, 6.2081, .0001, nil);
}

- (void)testNormalize {
	{
		ARQuaternion a = { 1.2, 2.3, 3.4, 4.5 };
		ARQuaternion correct = { 0.1933, 0.3705, 0.5477, 0.7249 };
		ARQuaternion testee = ARQuaternionNormalize(a);
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, .0001), nil);
	}
	
	{
		ARQuaternion a = ARQuaternionZero;
		ARQuaternion correct = ARQuaternionIdentity;
		ARQuaternion testee = ARQuaternionNormalize(a);
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, .0001), nil);
	}
}

- (void)testLERP:(ARQuaternion (*)(ARQuaternion, ARQuaternion, double))LERPFunction accuracy:(double)accuracy {
	{
		ARQuaternion a = { 0, 0, 1, 0 };
		ARQuaternion b = { 0, 0, -1, 0 };
		double correct = 0;
		double testee = LERPFunction(a, b, .5).w;
		GHAssertEqualsWithAccuracy(testee, correct, accuracy, nil);
	}
	
	{
		ARQuaternion a = { cos(45./2./180.*M_PI), 0, sin(45./2./180.*M_PI), 0 };
		ARQuaternion b = { -cos(45./2./180.*M_PI), 0, sin(45./2./180.*M_PI), 0 };
		ARQuaternion correct = ARQuaternionIdentity;
		ARQuaternion testee = LERPFunction(a, b, .5);
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, accuracy), nil);
	}
	
	{
		ARQuaternion a = { cos(-20./2./180.*M_PI), 0, sin(-20./2./180.*M_PI), 0 };
		ARQuaternion b = { cos(50./2./180.*M_PI), 0, sin(50./2./180.*M_PI), 0 };
		ARQuaternion correct = { cos(15./2./180.*M_PI), 0, sin(15./2./180.*M_PI), 0 };
		ARQuaternion testee = LERPFunction(a, b, .5);
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, accuracy), nil);
	}
	
	{
		ARQuaternion a = { cos(179./2./180.*M_PI), 0, sin(179./2./180.*M_PI), 0 };
		ARQuaternion b = { cos(-177./2./180.*M_PI), 0, sin(-177./2./180.*M_PI), 0 };
		ARQuaternion correct = { cos(-179./2./180.*M_PI), 0, sin(-179./2./180.*M_PI), 0 };
		ARQuaternion testee = LERPFunction(a, b, .5);
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, accuracy), nil);
	}
	
	{
		ARQuaternion a = { cos(179./2./180.*M_PI), 0, sin(179./2./180.*M_PI), 0 };
		ARQuaternion b = { cos(-179./2./180.*M_PI), 0, sin(-179./2./180.*M_PI), 0 };
		ARQuaternion correct = { cos(180./2./180.*M_PI), 0, sin(180./2./180.*M_PI), 0 };
		ARQuaternion testee = LERPFunction(a, b, .5);
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, accuracy), nil);
	}
	
	{
		ARQuaternion a = { cos(120./2./180.*M_PI), 0, sin(120./2./180.*M_PI), 0 };
		ARQuaternion b = { cos(-160./2./180.*M_PI), 0, sin(-160./2./180.*M_PI), 0 };
		ARQuaternion correct = { cos(140./2./180.*M_PI), 0, sin(140./2./180.*M_PI), 0 };
		ARQuaternion testee = LERPFunction(a, b, .25);
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, accuracy), nil);
	}
	
	{
		ARQuaternion a = { -0.270660881630335, 0.666250138099954, -0.688938633632480, -0.090647668064294 };
		ARQuaternion b = { -0.228059430331686, -0.511253112400869,  0.568408006472488, -0.602927433009299 };
		ARQuaternion correct = { -0.1259926117038532, 0.6761675775844262, -0.7127563323269639, 0.13748337916805106 };
		ARQuaternion testee = ARQuaternionNLERP(a, b, .3);
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, .01), nil);
	}
}

- (void)testNLERP {
	[self testLERP:&ARQuaternionNLERP accuracy:.01];
}

- (void)testSLERP {
	[self testLERP:&ARQuaternionSLERP accuracy:.000001];
}

- (void)testTransformPointQuaternion {
	ARQuaternion originalTransformQuaternion = { 0.193297123344084, -0.370486153076161, -0.547675182808238, 0.724864212540316 };
	ARQuaternion originalPointQuaternion = { 0, 10, 20, 30 };
	ARQuaternion correct = { 0, -2.548002075765440, -33.367929423975085, -16.735858847950180 };
	ARQuaternion testee = ARQuaternionTransformPointQuaternion(originalTransformQuaternion, originalPointQuaternion);
	GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, .0001), nil);}

- (void)testTransformPoint {
	ARQuaternion originalTransformQuaternion = { 0.193297123344084, -0.370486153076161, -0.547675182808238, 0.724864212540316 };
	ARPoint3D originalPoint = { 10, 20, 30 };
	ARPoint3D correct = { -2.548002075765440, -33.367929423975085, -16.735858847950180 };
	ARPoint3D testee = ARQuaternionTransformPoint(originalTransformQuaternion, originalPoint);
	GHAssertTrue(ARPoint3DEqualsWithAccuracy(testee, correct, .0001), nil);
}

- (void)testConvertToMatrix {
	ARQuaternion original = { 0.1933, -0.3705, -0.5477, 0.7249 };
	CATransform3D correct = {
		-0.6508,  0.1256, -0.7488, 0,
		 0.6860, -0.3254, -0.6508, 0,
		-0.3254, -0.9372,  0.1256, 0,
		      0,       0,       0, 1
	};
	CATransform3D testee = ARQuaternionConvertToMatrix(original);
	GHAssertTrue(ARTransform3DEqualsWithAccuracy(testee, correct, .0001), nil);
}

- (void)testRotateInDirection {
	GHFail(@"Not yet tested.");
}

- (void)testWeightedSum {
	GHFail(@"Not yet tested.");
}

- (void)testSphericalWeightedAverageInternal {
	ARQuaternion quaternions[0];
	double weights[0];
	ARQuaternion testee = ARQuaternionSphericalWeightedAverageInternal(0, quaternions, weights, ARQuaternionIdentity, 1e-6, 50);
	ARQuaternion correct = ARQuaternionIdentity;
	GHAssertTrue(ARQuaternionEqualsWithAccuracy(testee, correct, 1e-6), nil);
	
	// It is hard to come up with proper thorough test cases for this method; unit testing it is likely not beneficial
}

- (void)testSphericalWeightedAverage {
	// It is hard to come up with proper thorough test cases for this method; unit testing it is likely not beneficial
}

@end
