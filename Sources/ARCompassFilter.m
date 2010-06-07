//
//  ARCompassFilter.m
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

#import "ARCompassFilter.h"
#import "ARFilter.h"
#import "ARModifiedExponentialFilter.h"


@interface ARCompassCoordinateFilter : ARFilter {
@private
	ARModifiedExponentialFilter *modifiedExponential;
}

@end


@implementation ARCompassFilter

#pragma mark ARPoint3DFilter

- (ARFilter *)newCoordinateFilter {
	return [[ARCompassCoordinateFilter alloc] init];
}

@end


@implementation ARCompassCoordinateFilter

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		modifiedExponential = [[ARModifiedExponentialFilter alloc] initWithAlpha:0.1 delta:2.0];
	}
	return self;
}

- (void)dealloc {
	[modifiedExponential release];
	
	[super dealloc];
}

#pragma mark ARFilter

- (ARFilterValue)filterWithInput:(ARFilterValue)input {
	return [modifiedExponential filterWithInput:input];
}

@end
