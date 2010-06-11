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
#import "ARDerivativeSmoothFilter.h"


@interface ARAccelerometerCoordinateFilter : ARFilter {
@private
	ARDerivativeSmoothFilter *derivativeSmoothFilter;
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
		derivativeSmoothFilter = [[ARDerivativeSmoothFilter alloc] initWithBaseCorrectionFactor:0.1 correctionFactorDerivativeGain:0.1 derivativeAverageWindowSize:22];
	}
	return self;
}

- (void)dealloc {
	[derivativeSmoothFilter release];
	
	[super dealloc];
}

#pragma mark ARFilter

- (ARFilterValue)filterWithInput:(ARFilterValue)input timestamp:(NSTimeInterval)timestamp {
	return [derivativeSmoothFilter filterWithInput:input timestamp:timestamp];
}

@end
