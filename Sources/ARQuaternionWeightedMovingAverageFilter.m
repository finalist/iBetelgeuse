//
//  ARQuaternionWeightedMovingAverageFilter.m
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


#import "ARQuaternionWeightedMovingAverageFilter.h"


@implementation ARQuaternionWeightedMovingAverageFilter

#pragma mark NSObject

- (id)initWithWindowSize:(NSUInteger)windowSize {
	if (self = [super init]) {
		for (int i = 0; i < ARQuaternionCoordinateCount; ++i) {
			filters[i] = [[ARWeightedMovingAverageFilter alloc] initWithWindowSize:windowSize];
		}
	}
	return self;
}

- (void)dealloc {
	for (int i = 0; i < ARQuaternionCoordinateCount; ++i) {
		[filters[i] release];
	}
	[super dealloc];
}

#pragma mark ARQuaternionFilter

- (ARQuaternion)filterWithInput:(ARQuaternion)input weight:(double)weight {
	ARQuaternion output;
	double *inputs = (double*)&input;
	double *outputs = (double*)&output;
	for (int i = 0; i < ARQuaternionCoordinateCount; ++i) {
		outputs[i] = [filters[i] filterWithInput:inputs[i] weight:weight];
	}
	return output;
}

@end
