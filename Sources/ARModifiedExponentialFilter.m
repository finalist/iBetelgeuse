//
//  ARModifiedExponentialFilter.m
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

#import "ARModifiedExponentialFilter.h"


@implementation ARModifiedExponentialFilter

@synthesize alpha, delta;

#pragma mark NSObject

- (id)initWithAlpha:(double)anAlpha delta:(double)aDelta {
	NSAssert(anAlpha >= 0 && anAlpha <= 1, @"Expected alpha in range [0, 1].");
	NSAssert(aDelta >= 0, @"Expected delta in range [0, Inf).");
	
	if (self = [super init]) {
		alpha = anAlpha;
		delta = 0;
	}
	return self;
}

#pragma mark ARFilter

- (ARFilterValue)filterWithInput:(ARFilterValue)input {
	// Update baseline
	if (fabs(lastOutput - input) > delta || fabs(lastOutput - input) < fabs(lastOutput - baseline)) {
		baseline = input;
	}
	
	double deviation = baseline - lastOutput;
	double target = baseline + copysign(delta, deviation);
	
	double difference = target - lastOutput;
	double correction = copysign(alpha * fabs(difference), difference);
	
	ARFilterValue output;
	if (fabs(correction) > fabs(deviation)) {
		output = lastOutput; 
	}
	else {
		output = lastOutput + correction;
	}
	
	lastOutput = output;
	return output;
}

@end
