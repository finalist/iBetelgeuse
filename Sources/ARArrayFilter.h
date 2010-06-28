//
//  ARArrayFilter.h
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


/**
 * This class is used to filter an array of doubles, typically an ARQuaternion
 * or ARPoint3D.
 */
@interface ARArrayFilter : NSObject {
@private
	int size;
	ARFilter **filters;
}

/**
 * Initialize an array filter.
 * @param aSize the number of elements in each array to be filtered.
 * @param aFactory the factory that constructs a filter for each element.
 * @return the filter.
 */
- (id)initWithSize:(int)aSize factory:(ARFilterFactory *)aFactory;

/**
 * Filter an array of doubles.
 * @param input the input value array.
 * @param output the output value array
 * @param aTimestamp the time at which this sample was determined.
 */
- (void)filterWithInputArray:(const ARFilterValue *)input outputArray:(ARFilterValue *)output timestamp:(NSTimeInterval)aTimestamp;

@end
