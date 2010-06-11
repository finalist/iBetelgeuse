//
//  ARDoubleExponentialFilter.m
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


#import "ARDoubleExponentialFilter.h"


@implementation ARDoubleExponentialFilter

@synthesize alpha, gamma;

#pragma mark NSObject

- (id)initWithAlpha:(double)anAlpha {
	return [self initWithAlpha:anAlpha gamma:0.];
}

- (id)initWithAlpha:(double)anAlpha gamma:(double)aGamma {
	NSAssert(anAlpha >= 0 && anAlpha <= 1, @"Expected alpha to be in [0, 1].");
	NSAssert(aGamma >= 0 && aGamma <= 1, @"Expected gamma to be in [0, 1].");
	
	if (self = [super init]) {
		alpha = anAlpha;
		gamma = aGamma;
	}
	return self;
}

#pragma mark ARFilter

- (ARFilterValue)filterWithInput:(ARFilterValue)input timestamp:(NSTimeInterval)timestamp {
	ARFilterValue output;
	if (sampleCount == 0) {
		output = 0;
		trend = 0;
	} else {
		output = alpha * input + (1. - alpha) * (lastOutput + trend);
		trend = gamma * (output - lastOutput) + (1. - gamma) * trend;
	}
	lastOutput = output;
	++sampleCount;
	return output;
}

- (void)setGamma:(double)aGamma {
	gamma = aGamma;
	
	trend = 0;
}

@end
