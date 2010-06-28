//
//  ARSphericalMovingAverageQuaternionFilter.m
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


#import "ARSphericalMovingAverageQuaternionFilter.h"
#import "ARQuaternion.h"


@implementation ARSphericalMovingAverageQuaternionFilter

#pragma mark NSObject

- (id)initWithWindowSize:(NSUInteger)aWindowSize {
	if (self = [super init]) {
		weights = malloc(aWindowSize * sizeof(double));
		sampleBuffer = [[ARCyclicBuffer alloc] initWithElementSize:sizeof(ARQuaternion) maxElementCount:aWindowSize];
	}
	return self;
}

- (void)dealloc {
	[sampleBuffer release];
	free(weights);
	[super dealloc];
}

#pragma mark ARQuaternionFilter

- (ARQuaternion)filterWithInput:(ARQuaternion)input timestamp:(NSTimeInterval)aTimestamp {
	[sampleBuffer pushElement:&input];
	
	const ARQuaternion *samples = [sampleBuffer elements];
	int sampleCount = [sampleBuffer elementCount];
	
	// Average with equal weights. Could be optimized to do this only once.
	for (int i = 0; i < sampleCount; ++i) {
		weights[i] = 1. / sampleCount;
	}
	
	ARQuaternion output = ARQuaternionSphericalWeightedAverage(sampleCount, samples, weights, 1.e-6, 50);
	return output;
}

@end
