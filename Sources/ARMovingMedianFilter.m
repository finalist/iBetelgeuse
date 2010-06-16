//
//  ARMovingMedianFilter.m
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


#import "ARMovingMedianFilter.h"


@implementation ARMovingMedianFilter

#pragma mark NSObject

- (id)initWithWindowSize:(NSUInteger)aWindowSize {
	if (self = [super initWithWindowSize:aWindowSize]) {
		sortedSamples = calloc([self windowSize], sizeof(sortedSamples[0]));
	}
	return self;
}

- (void)dealloc {
	free(sortedSamples);
	
	[super dealloc];
}

#pragma mark ARMovingWindowFilter

int ARMovingMedianFilterSampleCompare(const ARFilterValue *a, const ARFilterValue *b) {
	return *b > *a ? 1 : -1;
}

- (ARFilterValue)filterWithSampleValues:(ARFilterValue *)sampleValues sampleTimestamps:(NSTimeInterval *)sampleTimestamps lastSampleIndex:(NSUInteger)sampleIndex sampleCount:(NSUInteger)sampleCount {
	memcpy(sortedSamples, sampleValues, sampleCount * sizeof(sortedSamples[0]));
	qsort(sortedSamples, sampleCount, sizeof(sortedSamples[0]), (int (*)(const void *, const void *))ARMovingMedianFilterSampleCompare);
	
	if (sampleCount % 2 == 0) {
		return (sortedSamples[sampleCount / 2 - 1] + sortedSamples[sampleCount / 2]) / 2.;
	}
	else {
		return sortedSamples[sampleCount / 2];
	}
}

@end


@implementation ARMovingMedianFilterFactory

- (ARFilter *)newFilter {
	return [[ARMovingMedianFilter alloc] initWithWindowSize:[self windowSize]];
}

@end
