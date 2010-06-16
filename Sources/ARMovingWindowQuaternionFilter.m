//
//  ARMovingWindowQuaternionFilter.m
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


#import "ARMovingWindowQuaternionFilter.h"


@implementation ARMovingWindowQuaternionFilter

@synthesize windowSize;

#pragma mark NSObject

- (id)initWithWindowSize:(NSUInteger)aWindowSize {
	NSAssert(aWindowSize > 0, @"Expected window size larger than 0.");
	
	if (self = [super init]) {
		windowSize = aWindowSize;
		sampleValues = malloc(windowSize * sizeof(sampleValues[0]));
		sampleTimestamps = malloc(windowSize * sizeof(sampleTimestamps[0]));
		
		NSTimeInterval currentTime = [[NSDate date] timeIntervalSinceReferenceDate];
		for (int i = 0; i < windowSize; ++i) {
			sampleValues[i] = ARQuaternionIdentity;
			sampleTimestamps[i] = currentTime;
		}
	}
	return self;
}

- (void)dealloc {
	free(sampleValues);
	free(sampleTimestamps);
	
	[super dealloc];
}

#pragma mark ARFilter

- (ARQuaternion)filterWithInput:(ARQuaternion)input timestamp:(NSTimeInterval)timestamp {
	NSUInteger previousSampleIndex = sampleIndex;
	
	sampleValues[sampleIndex] = input;
	sampleTimestamps[sampleIndex] = timestamp;
	sampleIndex = (sampleIndex + 1) % windowSize;
	sampleCount = MIN(sampleCount + 1, windowSize);
	
	return [self filterWithSampleValues:sampleValues sampleTimestamps:sampleTimestamps lastSampleIndex:previousSampleIndex sampleCount:sampleCount];
}

#pragma mark ARMovingWindowQuaternionFilter

- (ARQuaternion)filterWithSampleValues:(ARQuaternion *)someSampleValues sampleTimestamps:(NSTimeInterval *)someSampleTimestamps lastSampleIndex:(NSUInteger)aSampleIndex sampleCount:(NSUInteger)sampleCount {
	return someSampleValues[aSampleIndex];
}

@end
