//
//  ARCyclicBuffer.h
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

#import <Foundation/Foundation.h>


/**
 * This class implements a cyclic buffer with a maximum number of elements. If
 * the maximum is exceeded, the oldest element will be removed.
 */
@interface ARCyclicBuffer : NSObject {
@private
	int elementSize;
	int elementCount;
	int maxElementCount;
	void *elements;
	int oldestElementIndex;
}

/**
 * Initialize the buffer.
 *
 * @param elementSize the size (in bytes) of one element.
 * @param maxElementCount the maximum number of elements to store.
 *
 * @return the initialized buffer.
 */
- (id)initWithElementSize:(int)elementSize maxElementCount:(int)maxElementCount;

/**
 * The current elements, unordered.
 */
@property(nonatomic, readonly) const void *elements;

/**
 * The size of elements in the buffer.
 */
@property(nonatomic, readonly) int elementSize;

/**
 * The number of elements currently in the buffer.
 */
@property(nonatomic, readonly) int elementCount;

/**
 * The value of the oldest element in the buffer.
 */
@property(nonatomic, readonly) const void *oldestElement;

/**
 * Push an element into this buffer, if the buffer is full, the oldest element
 * will be removed.
 *
 * @param element the element that is to be added.
 */
- (void)pushElement:(const void *)element;

@end
