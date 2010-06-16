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

#pragma mark ARMovingWindowFilter

- (ARFilterValue)filterWithSampleValues:(ARFilterValue *)sampleValues sampleTimestamps:(NSTimeInterval *)sampleTimestamps lastSampleIndex:(NSUInteger)sampleIndex sampleCount:(NSUInteger)sampleCount {
	NSUInteger oldestSampleIndex = (sampleIndex + 1) % sampleCount;
	ARFilterValue oldestSample = sampleValues[oldestSampleIndex];
	return oldestSample;
}

@end


@implementation ARDelayFilterFactory

#pragma mark ARFilterFactory

- (ARFilter *)newFilter {
	return [[ARDelayFilter alloc] initWithWindowSize:[self windowSize]];
}

@end
