//
//  ARWeightedMovingAverageQuaternionFilter.h
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
#import "ARQuaternion.h"


/**
 * This implements an elementwise weighted moving average filter for quaternions.
 * @see ARWeightedMovingAverageFilter
 */
@interface ARWeightedMovingAverageQuaternionFilter : NSObject {
@private
	ARWeightedMovingAverageFilter *filters[ARQuaternionCoordinateCount];
}

/**
 * This function takes a new input value, processes it and generates an output
 * value by applying the weighted moving average filter on all elements of the
 * quaternion.
 * @param input the current value of the signal
 * @param weight the weight of this value.
 * @return the output of the filter.
 */
- (ARQuaternion)filterWithInput:(ARQuaternion)input weight:(double)weight;

@end
