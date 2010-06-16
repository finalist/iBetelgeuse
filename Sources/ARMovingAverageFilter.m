//
//  ARMovingAverageFilter.m
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


#import "ARMovingAverageFilter.h"


@implementation ARMovingAverageFilter

#pragma mark ARMovingWindowFilter

- (ARFilterValue)filterWithSampleValues:(ARFilterValue *)sampleValues sampleTimestamps:(NSTimeInterval *)sampleTimestamps lastSampleIndex:(NSUInteger)sampleIndex sampleCount:(NSUInteger)sampleCount {
	ARFilterValue sum = 0;
	double totalWeight = 0;
	
	// Compute average weighted by time step
	for (NSUInteger i = 0; i < sampleCount; i++) {
		double weight = sampleTimestamps[i] - sampleTimestamps[(i + sampleCount - 1) % sampleCount];
		if (weight < 0) {
			weight = 0;
		}
		totalWeight += weight;
		sum += sampleValues[i] * weight;
	}
	
	// If all weights are zero, recompute average weighing every sample equally. (This happens at least when the first value is received, and in the unlikely case when all timestamps are equal)
	if (totalWeight == 0) {
		sum = 0;
		for (NSUInteger i = 0; i < sampleCount; i++) {
			sum += sampleValues[i];
		}
		totalWeight = sampleCount;
	}
	
	ARFilterValue output = sum / totalWeight;
	return output;
}

@end


@implementation ARMovingAverageFilterFactory

- (ARFilter *)newFilter {
	return [[ARMovingAverageFilter alloc] initWithWindowSize:[self windowSize]];
}

@end