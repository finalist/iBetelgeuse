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
#import "ARSimplePoint3DFilter.h"
#import "ARDelayFilter.h"


@implementation ARAccelerometerFilter

#pragma mark ARAccelerometerFilter

- (id)init {
	if (self = [super init]) {
		ARDelayFilterFactory *delayFilterFactory = [[ARDelayFilterFactory alloc] initWithWindowSize:2]; // One sample seems to be enough.
		delayFilter = [[ARSimplePoint3DFilter alloc] initWithFactory:delayFilterFactory];
		[delayFilterFactory release];
	}
	return self;
}

- (void)dealloc {
	[delayFilter release];
	[super dealloc];
}

- (ARPoint3D)filterWithInput:(ARPoint3D)input timestamp:(NSTimeInterval)aTimestamp {
	return [delayFilter filterWithInput:input timestamp:aTimestamp];
}

@end
