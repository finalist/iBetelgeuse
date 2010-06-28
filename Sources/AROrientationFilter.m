//
//  AROrientationFilter.m
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


#import "AROrientationFilter.h"
#import "ARDerivativeSmoothQuaternionFilter.h"


#define BASE_CORRECTION_FACTOR					0.03
#define CORRECTION_FACTOR_DERIVATIVE_GAIN		0.3
#define STABILIZER_ANGULAR_VELOCITY				(10 / 180. * M_PI)
#define DERIVATIVE_AVERAGE_WINDOW_SIZE			33
#define CORRECTING_INPUT_AVERAGE_WINDOW_SIZE	7


@implementation AROrientationFilter

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		quaternionFilter = [[ARDerivativeSmoothQuaternionFilter alloc] initWithBaseCorrectionFactor:BASE_CORRECTION_FACTOR correctionFactorDerivativeGain:CORRECTION_FACTOR_DERIVATIVE_GAIN stabilizerAngularVelocity:STABILIZER_ANGULAR_VELOCITY derivativeAverageWindowSize:DERIVATIVE_AVERAGE_WINDOW_SIZE correctingInputAverageWindowSize:CORRECTING_INPUT_AVERAGE_WINDOW_SIZE];
	}
	return self;
}

- (void)dealloc {
	[quaternionFilter release];
	[super dealloc];
}

#pragma mark ARQuaternionFilter

- (ARQuaternion)filterWithInput:(ARQuaternion)input timestamp:(NSTimeInterval)timestamp {
	return [quaternionFilter filterWithInput:input timestamp:timestamp];
}

@end
