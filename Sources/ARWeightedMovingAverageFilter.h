//
//  ARWeightedMovingAverageFilter.h
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


#import "ARFilter.h"
#import "ARCyclicBuffer.h"


/**
 * This struct is used to store combined value/weight pairs in a buffer.
 */
typedef struct {
	ARFilterValue value;
	double weight;
} ARWeightedFilterValue;


/**
 * This filter computes the moving average with a given window.
 */
@interface ARWeightedMovingAverageFilter : NSObject {
@private
	ARCyclicBuffer *sampleBuffer;
}

/**
 * Initialize the filter.
 * @param windowSize the desired size.
 * @return The initialized filter.
 */
- (id)initWithWindowSize:(NSUInteger)windowSize;

/**
 * Apply the filter to a new sample. This will multiply all samples by their
 * weights, and divide the sum of these weighted values by the sum of their
 * weights.
 * @param input the input value.
 * @param weight the weight of this input value.
 * @return the output value.
 */
- (ARFilterValue)filterWithInput:(ARFilterValue)input weight:(double)weight;

@end

