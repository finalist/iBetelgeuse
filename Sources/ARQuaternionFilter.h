//
//  ARQuaternionFilter.h
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


#import "ARQuaternion.h"


/**
 * This is the base class of all ARQuaternion filters.
 */
@interface ARQuaternionFilter : NSObject {
}

/**
 * This function takes a new input value, processes it and generates an output
 * value. Child classes should override this function to implement useful
 * filtering.
 * @param input the current value of the signal.
 * @param aTimestamp a relative timestamp; this value is guaranteed to be greater than or equal to previously provided timestamps, but does not necessarily represent an accurate UNIX timestamp.
 * @return the output of the filter.
 */
- (ARQuaternion)filterWithInput:(ARQuaternion)input timestamp:(NSTimeInterval)aTimestamp;

@end
