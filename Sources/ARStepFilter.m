//
//  ARStepFilter.m
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

#import "ARStepFilter.h"


@implementation ARStepFilter

#pragma mark NSObject

- (id)initWithStepThreshold:(ARFilterValue)aStepThreshold referenceInput:(ARFilterValue)aReferenceInput {
	if (self = [super init]) {
		stepThreshold = aStepThreshold;
		referenceInput = aReferenceInput;
	}
	return self;
}

#pragma mark ARFilter

- (ARFilterValue)filterWithInput:(ARFilterValue)input timestamp:(NSTimeInterval)timestamp {
	if (fabs(input - referenceInput) > stepThreshold) {
		referenceInput = input;
	}
	return referenceInput;
}

@end


@implementation ARStepFilterFactory

#pragma mark NSObject

- (id)initWithStepThreshold:(ARFilterValue)aStepThreshold referenceInput:(ARFilterValue)aReferenceInput {
	if (self = [super init]) {
		stepThreshold = aStepThreshold;
		referenceInput = aReferenceInput;
	}
	return self;
}

#pragma mark ARFilterFactory

- (ARFilter *)newFilter {
	return [[ARStepFilter alloc] initWithStepThreshold:stepThreshold referenceInput:referenceInput];
}

@end
