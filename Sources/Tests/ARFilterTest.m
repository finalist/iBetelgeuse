//
//  ARFilterTest.m
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

#import "ARFilterTest.h"
#import "ARFilter.h"
#import <GHUnit/GHUnit.h>


@implementation ARFilterTest

#pragma mark GHTestCase

- (void)testConstantInputWithFilterFactory:(ARFilterFactory *)filterFactory input:(ARFilterValue)input sampleCount:(int)sampleCount accuracy:(ARFilterValue)accuracy {
	ARFilter *filter = [filterFactory newFilter];
	for (int i = 0; i < sampleCount; ++i) {
		NSTimeInterval timestamp = 100 + floor(i/3); // Give the same value three times in a row, before updating to a new timestamp.
		ARFilterValue output = [filter filterWithInput:input timestamp:timestamp];
		GHAssertEqualsWithAccuracy(output, input, accuracy, nil);
	}
	[filter release];
}

@end
