//
//  ARDerivativeSmoothFilter.m
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


#import "ARDerivativeSmoothFilter.h"


@implementation ARDerivativeSmoothFilter

#pragma mark NSObject

- (id)initWithBaseCorrectionFactor:(ARFilterValue)aBaseCorrectionFactor correctionFactorDerivativeGain:(ARFilterValue)aCorrectionFactorDerivativeGain derivativeAverageWindowSize:(ARFilterValue)aDerivativeAverageWindowSize {
	if (self = [super init]) {
		baseCorrectionFactor = aBaseCorrectionFactor;
		correctionFactorDerivativeGain = aCorrectionFactorDerivativeGain;
		derivativeFilter = [[ARDerivativeFilter alloc] init];
		derivativeAverageFilter = [[ARMovingAverageFilter alloc] initWithWindowSize:aDerivativeAverageWindowSize];
		inputAverageFilter = [[ARMovingAverageFilter alloc] initWithWindowSize:7];
	}
	return self;
}

- (void)dealloc {
	[derivativeFilter release];
	[derivativeAverageFilter release];
	[inputAverageFilter release];
	[super dealloc];
}

#pragma mark ARFilter

- (ARFilterValue)filterWithInput:(ARFilterValue)input timestamp:(NSTimeInterval)timestamp {
	ARFilterValue output;
	if (sampleCount == 0) {
		output = input;
	} else {
		ARFilterValue timeStep = timestamp - lastTimestamp;
		ARFilterValue derivative = [derivativeAverageFilter filterWithInput:[derivativeFilter filterWithInput:input timestamp:timestamp] timestamp:timestamp];
		ARFilterValue correctionFactor = fmin(1., baseCorrectionFactor + correctionFactorDerivativeGain * abs(derivative));
		ARFilterValue estimate = lastOutput + derivative * timeStep;
		ARFilterValue inputAverage = [inputAverageFilter filterWithInput:input timestamp:timestamp];
		output = (1 - correctionFactor) * estimate + correctionFactor * inputAverage;
	}
	lastOutput = output;
	lastTimestamp = timestamp;
	++sampleCount;
	return output;
}

@end
