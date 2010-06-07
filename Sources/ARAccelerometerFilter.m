//
//  ARAccelerometerFilter.m
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

#import "ARAccelerometerFilter.h"
#import "ARFilter.h"
#import "ARMovingMedianFilter.h"
#import "ARMovingAverageFilter.h"


@interface ARAccelerometerCoordinateFilter : ARFilter {
@private
	ARMovingMedianFilter *movingMedian;
	ARMovingAverageFilter *movingAverage;
}

@end


@implementation ARAccelerometerFilter

#pragma mark ARPoint3DFilter

- (ARFilter *)newCoordinateFilter {
	 return [[ARAccelerometerCoordinateFilter alloc] init];
}

@end


@implementation ARAccelerometerCoordinateFilter

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		movingMedian = [[ARMovingMedianFilter alloc] initWithWindowSize:11];
		movingAverage = [[ARMovingAverageFilter alloc] initWithWindowSize:5];
	}
	return self;
}

- (void)dealloc {
	[movingMedian release];
	[movingAverage release];
	
	[super dealloc];
}

#pragma mark ARFilter

- (ARFilterValue)filterWithInput:(ARFilterValue)input {
	return [movingAverage filterWithInput:[movingMedian filterWithInput:input]];
}

@end
