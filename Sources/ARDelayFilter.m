//
//  ARDelayFilter.m
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


#import "ARDelayFilter.h"


@implementation ARDelayFilter

#pragma mark NSObject

- (id)initWithDelay:(NSUInteger)delay {
	if (self = [super init]) {
		sampleBuffer = [[ARCyclicBuffer alloc] initWithElementSize:sizeof(ARFilterValue) maxElementCount:delay+1];
	}
	return self;
}

#pragma mark ARFilter

- (ARFilterValue)filterWithInput:(ARFilterValue)input timestamp:(NSTimeInterval)timestamp {
	[sampleBuffer pushElement:&input];
	ARFilterValue oldestSampleValue = *(ARFilterValue*)[sampleBuffer oldestElement];
	return oldestSampleValue;
}

@end


@implementation ARDelayFilterFactory

#pragma mark NSObject

- (id)initWithDelay:(NSUInteger)aDelay {
	if (self = [super init]) {
		delay = aDelay;
	}
	return self;
}

#pragma mark ARFilterFactory

- (ARFilter *)newFilter {
	return [[ARDelayFilter alloc] initWithDelay:delay];
}

@end
