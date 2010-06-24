//
//  ARSimplePoint3DFilter.h
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


#import "ARPoint3DFilter.h"

@class ARArrayFilter, ARFilterFactory;


/**
 * This class is a wrapper around ARArrayFilter, so that ARPoint3D objects can
 * be easily filtered, using the same type of filter with the same parameters
 * for each coordinate.
 */
@interface ARSimplePoint3DFilter : ARPoint3DFilter {
	ARArrayFilter *arrayFilter;
}

/**
 * Initialize a point filter.
 * @param aFactory the factory that should be used to create the filters for
 *   each coordinate of the point.
 * @return the initialized filter.
 */
- (id)initWithFactory:(ARFilterFactory *)aFactory;

@end
