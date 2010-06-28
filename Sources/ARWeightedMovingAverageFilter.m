//
//  ARWeightedMovingAverageFilter.m
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


#import "ARWeightedMovingAverageFilter.h"


@implementation ARWeightedMovingAverageFilter

#pragma mark NSObject

- (id)initWithWindowSize:(NSUInteger)windowSize {
	if (self = [super init]) {
		sampleBuffer = [[ARCyclicBuffer alloc] initWithElementSize:sizeof(ARWeightedFilterValue) maxElementCount:windowSize];
	}
	return self;
}

- (void)dealloc {
	[sampleBuffer release];
	
	[super dealloc];
}

#pragma mark ARWeightedMovingAverageFilter

- (ARFilterValue)filterWithInput:(ARFilterValue)input weight:(double)weight {
	ARWeightedFilterValue value = {input, weight};
	[sampleBuffer pushElement:&value];
	
	const ARWeightedFilterValue *samples = [sampleBuffer elements];
	int sampleCount = [sampleBuffer elementCount];
	
	ARFilterValue sum = 0;
	double totalWeight = 0;
	
	// Compute average weighted by time step
	for (NSUInteger i = 0; i < sampleCount; i++) {
		totalWeight += samples[i].weight;
		sum += samples[i].value * samples[i].weight;
	}
	
	// If all weights are zero, recompute the average by weighing every sample equally. (This happens at least when the first value is received, and in the unlikely case when all samples are determined at the same time)
	if (totalWeight == 0) {
		sum = 0;
		for (NSUInteger i = 0; i < sampleCount; i++) {
			sum += samples[i].value;
		}
		totalWeight = sampleCount;
	}
	
	ARFilterValue output = sum / totalWeight;
	return output;
}

@end
