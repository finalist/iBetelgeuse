//
//  ARDerivativeFilter.m
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


#import "ARDerivativeFilter.h"


// TODO: Refactor to get rid of this class; taking the derivative is not a filter.
@implementation ARDerivativeFilter

#pragma mark ARFilter

- (ARFilterValue)filterWithInput:(ARFilterValue)input timestamp:(NSTimeInterval)timestamp {
	ARFilterValue output;
	if (sampleCount == 0) {
		output = 0;
	} else {
		NSTimeInterval timeStep = timestamp - lastTimestamp;
		if (timeStep == 0) {
			return lastOutput; // Since we cannot give a meaningful output value, ignore this sample and return the previous value. Do not update the filter state.
		} else {
			output = (input - lastInput) / timeStep;
		}
	}
	lastInput = input;
	lastTimestamp = timestamp;
	lastOutput = output;
	++sampleCount;
	return output;
}

@end
