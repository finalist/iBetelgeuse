//
//  ARMovingWindowFilter.m
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


#import "ARMovingWindowFilter.h"


@implementation ARMovingWindowFilter

@synthesize windowSize;

#pragma mark NSObject

- (id)initWithWindowSize:(NSUInteger)aWindowSize {
	NSAssert(aWindowSize > 0, @"Expected window size larger than 0.");
	
	if (self = [super init]) {
		windowSize = aWindowSize;
		
		samples = calloc(windowSize, sizeof(samples[0]));
	}
	return self;
}

- (void)dealloc {
	free(samples);
	
	[super dealloc];
}

#pragma mark ARFilter

- (ARFilterValue)filterWithInput:(ARFilterValue)input timestamp:(NSTimeInterval)timestamp {
	NSUInteger previousSampleIndex = sampleIndex;
	
	samples[sampleIndex++] = input;
	if (sampleIndex >= windowSize) {
		sampleIndex = 0;
	}
	sampleCount = MIN(sampleCount + 1, windowSize);
	
	return [self filterWithSamples:samples lastSampleIndex:previousSampleIndex sampleCount:sampleCount];
}

#pragma mark ARMovingWindowFilter

- (ARFilterValue)filterWithSamples:(ARFilterValue *)someSamples lastSampleIndex:(NSUInteger)aSampleIndex sampleCount:(NSUInteger)aSampleCount {
	return someSamples[aSampleIndex];
}

@end
