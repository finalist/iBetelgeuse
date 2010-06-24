//
//  ARMovingWindowQuaternionFilter.h
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


#include "ARQuaternionFilter.h"


/**
 * This is an abstract filter class, which implements a moving window that can
 * be used by child classes to access a fixed number of previous inputs.
 */
@interface ARMovingWindowQuaternionFilter : ARQuaternionFilter {
	NSUInteger windowSize;
	
	ARQuaternion *sampleValues; // A circular buffer of sample values.
	NSTimeInterval *sampleTimestamps; // A circular buffer of timestamps, corresponding to the sample values.
	NSUInteger sampleIndex; // The most recent sample's index.
	NSUInteger sampleCount; // The amount of samples, if enough samples are available, this will be equal to the window size.
}

/**
 * The size of the window that will be stored; this many samples will be stored.
 */
@property(nonatomic, readonly) NSUInteger windowSize;

/**
 * Initialize a filter with a given window size.
 * @param windowSize the desired window size.
 * @return the filter.
 */
- (id)initWithWindowSize:(NSUInteger)windowSize;

/**
 * Applies the filter function on the determined window. This should be overridden by a child class.
 * @param sampleValues the sampled values.
 * @param sampleTimestamps the timestamps corresponding to the timestamps.
 * @param sampleIndex the index of the most recent sample in the array. The previous sample is in index (sampleIndex-1) or at the end of the array if (sampleIndex == 0).
 * @param sampleCount the number of actually measured samples; this value is always smaller than windowSize.
 * @return the filtered value.
 */
- (ARQuaternion)filterWithSampleValues:(ARQuaternion *)sampleValues sampleTimestamps:(NSTimeInterval *)sampleTimestamps lastSampleIndex:(NSUInteger)sampleIndex sampleCount:(NSUInteger)sampleCount;

@end
