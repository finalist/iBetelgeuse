//
//  ARDerivativeSmoothQuaternionFilter.m
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


#import "ARDerivativeSmoothQuaternionFilter.h"
#import "ARSimpleQuaternionFilter.h"
#import "ARMovingAverageFilter.h"
#import "ARMovingAverageQuaternionFilter.h"


@implementation ARDerivativeSmoothQuaternionFilter

#pragma mark NSObject

- (id)initWithBaseCorrectionFactor:(double)aBaseCorrectionFactor correctionFactorDerivativeGain:(double)aCorrectionFactorDerivativeGain stabilizerAngularVelocity:(double)aStabilizerAngularVelocity derivativeAverageWindowSize:(int)aDerivativeAverageWindowSize correctingInputAverageWindowSize:(int)aCorrectingInputAverageWindowSize {
	if (self = [super init]) {
		baseCorrectionFactor = aBaseCorrectionFactor;
		correctionFactorDerivativeGain = aCorrectionFactorDerivativeGain;
		stabilizerAngularVelocity = aStabilizerAngularVelocity;
		
		ARFilterFactory *derivativeAverageFilterFactory = [[ARMovingAverageFilterFactory alloc] initWithWindowSize:aDerivativeAverageWindowSize];
		derivativeAverageFilter = [[ARSimpleQuaternionFilter alloc] initWithFactory:derivativeAverageFilterFactory];
		correctingInputAverageFilter = [[ARMovingAverageQuaternionFilter alloc] initWithWindowSize:aCorrectingInputAverageWindowSize];
		[derivativeAverageFilterFactory release];
	}
	return self;
}

- (void)dealloc {
	[derivativeAverageFilter release];
	[correctingInputAverageFilter release];
	[super dealloc];
}

#pragma mark ARFilter

- (ARQuaternion)filterWithInput:(ARQuaternion)input timestamp:(NSTimeInterval)timestamp {
	NSAssert(fabs(ARQuaternionNorm(input) - 1.) < ARQuaternionEpsilon, @"Expected input to be a unit quaternion.");
	ARQuaternion output;
	if (sampleCount == 0) {
		output = input;
	} else {
		// If the quaternions are not on the same hemisphere, invert one of them so that they are.
		if (ARQuaternionDotProduct(input, lastInput) < 0) {
			lastInput = ARQuaternionNegate(lastInput);
		}
		
		NSTimeInterval timeStep = timestamp - lastTimestamp;
		
		// Derive input:  dq/dt = (q_n - q_(n-1)) / dt
		ARQuaternion inputDerivative = ARQuaternionMultiplyByScalar(ARQuaternionSubtract(input, lastInput), 1. / timeStep);
		
		// Compute input angular velocity from quaternion derivative:  let q = q_(n-1) in  w = inv(q) * (dq/dt) * 2. inv(q) = conj(q) because |q| = 1
		ARQuaternion inputAngularVelocity = ARQuaternionMultiply(ARQuaternionConjugate(lastInput), ARQuaternionMultiplyByScalar(inputDerivative, 2.));
		
		// Filter angular velocity
		ARQuaternion outputAngularVelocity = [derivativeAverageFilter filterWithInput:inputAngularVelocity timestamp:timestamp];
		
		// Apply stabilizer:  reduce angular velocity by a fixed amount (without changing the direction). This leads to a slightly longer response time, but removes noise.
		if (ARQuaternionNorm(outputAngularVelocity) < stabilizerAngularVelocity) {
			outputAngularVelocity = ARQuaternionZero;
		} else {
			outputAngularVelocity = ARQuaternionSubtract(outputAngularVelocity, ARQuaternionMultiplyByScalar(ARQuaternionNormalize(outputAngularVelocity), stabilizerAngularVelocity));
		}
		
		// Compute quaternion derivative of estimate from angular velocity:  dq'/dt = 1/2 * q * w
		ARQuaternion outputDerivative = ARQuaternionMultiplyByScalar(ARQuaternionMultiply(lastOutput, outputAngularVelocity), .5);
		
		// Integrate quaternion derivative of estimate:  q' = q + dt * (dq'/dt)
		ARQuaternion estimate = ARQuaternionAdd(lastOutput, ARQuaternionMultiplyByScalar(outputDerivative, timeStep));
		
		// Compute correction factor:  correction factor is increased if the device is moving faster, to allow for faster convergence
		double correctionFactor = fmin(1., baseCorrectionFactor + correctionFactorDerivativeGain * ARQuaternionNorm(outputAngularVelocity));
		
		// Compute linear interpolation between estimate and correct input value, given the correctionFactor.
		ARQuaternion correctingInputAverage = [correctingInputAverageFilter filterWithInput:input timestamp:timestamp];
		output = ARQuaternionSLERP(estimate, correctingInputAverage, correctionFactor);
		output = ARQuaternionNormalize(output);
	}
	
	lastInput = input;
	lastOutput = output;
	lastTimestamp = timestamp;
	++sampleCount;
	
	return output;
}

@end
