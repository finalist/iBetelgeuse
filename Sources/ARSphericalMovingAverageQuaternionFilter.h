//
//  ARSphericalMovingAverageQuaternionFilter.h
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


#import "ARQuaternionFilter.h"
#import "ARCyclicBuffer.h"


/**
 * This filter computes a spherical average of the values a fixed size moving
 * window.
 */
@interface ARSphericalMovingAverageQuaternionFilter : ARQuaternionFilter {
	double *weights;
	ARCyclicBuffer *sampleBuffer;
}

/**
 * Initialize the filter
 * @param aWindowSize the window size to be used.
 * @return the initialized filter.
 */
- (id)initWithWindowSize:(NSUInteger)aWindowSize;

@end
