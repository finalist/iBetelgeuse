//
//  ARAccelerometerFilter.h
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


/**
 * The filter that is used for filtering accelerometer data. Note that most of
 * the actual filtering is actually done when the quaternion is constructed.
 * This filter only delays the accelerometer signal slightly, because it seems
 * to be slightly ahead on the compass.
 */
@interface ARAccelerometerFilter : ARPoint3DFilter {
	ARPoint3DFilter *delayFilter;
}

@end
