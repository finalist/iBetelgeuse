//
//  ARWeightedMovingAverageFilterTest.m
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

#import "ARWeightedMovingAverageFilterTest.h"
#import "ARWeightedMovingAverageFilter.h"
#import <GHUnit/GHUnit.h>


@implementation ARWeightedMovingAverageFilterTest

#pragma mark GHTestCase

- (void)testRandomValues {
	const int sampleCount = 20;
	
	const double inputs[] = {
		-0.648251168632938,
		0.443516066782205,
		-0.053028014069359,
		-0.694557599123536,
		-0.317750785901781,
		0.214778427536695,
		-0.616509489076404,
		0.476853679953883,
		-0.514300803363662,
		0.834848684098765,
		-0.461876826627963,
		0.531000033242877,
		-0.622676046417018,
		-0.425003653867738,
		-0.817773072626930,
		0.152418761326014,
		0.366726486589306,
		0.093186229180646,
		-0.148542316257624,
		0.288885562862673,
	};
	
	const NSTimeInterval weights[] = {
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.635786710514084,
		0.647617630172684,
		0.661944751905652,
		0.662009598359135,
		0.679016754093202,
		0.709281702710545,
		0.770285514803660,
		0.832916819075216,
		0.841929152691309,
		0.945174113109401,
	};
	
	const ARFilterValue correctOutputs[] = {
		-0.648251168632938,
		-0.102367550925366,
		-0.085921038640031,
		-0.238080178760907,
		-0.254014300189082,
		-0.175882178901452,
		-0.238828937497874,
		-0.149368610316404,
		-0.189916631766100,
		-0.087440100179613,
		-0.461876826627963,
		0.039137965560420,
		-0.186057765958537,
		-0.246726239319449,
		-0.364713478961317,
		-0.272915703938609,
		-0.169534872714679,
		-0.130451051230608,
		-0.132815911234573,
		-0.078851204072299,
	};
	
	ARWeightedMovingAverageFilter *filter = [[ARWeightedMovingAverageFilter alloc] initWithWindowSize:10];
	for (int i = 0; i < sampleCount; ++i) {
		// Fetch variables.
		ARFilterValue input = inputs[i];
		double weight = weights[i];
		ARFilterValue correctOutput = correctOutputs[i];
		
		// Process filter.
		ARFilterValue output = [filter filterWithInput:input weight:weight];
		
		// Check value.
		GHAssertEqualsWithAccuracy(output, correctOutput, 1e-6, nil);
	}
	[filter release];
}

- (void)testIdentity {
	const int sampleCount = 20;
	
	const double inputs[] = {
		-0.648251168632938,
		0.443516066782205,
		-0.053028014069359,
		-0.694557599123536,
		-0.317750785901781,
		0.214778427536695,
		-0.616509489076404,
		0.476853679953883,
		-0.514300803363662,
		0.834848684098765,
		-0.461876826627963,
		0.531000033242877,
		-0.622676046417018,
		-0.425003653867738,
		-0.817773072626930,
		0.152418761326014,
		0.366726486589306,
		0.093186229180646,
		-0.148542316257624,
		0.288885562862673,
	};
	
	const NSTimeInterval weights[] = {
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.000000000000000,
		0.635786710514084,
		0.647617630172684,
		0.661944751905652,
		0.662009598359135,
		0.679016754093202,
		0.709281702710545,
		0.770285514803660,
		0.832916819075216,
		0.841929152691309,
		0.945174113109401,
	};
	
	const ARFilterValue correctOutputs[] = {
		-0.648251168632938,
		0.443516066782205,
		-0.053028014069359,
		-0.694557599123536,
		-0.317750785901781,
		0.214778427536695,
		-0.616509489076404,
		0.476853679953883,
		-0.514300803363662,
		0.834848684098765,
		-0.461876826627963,
		0.531000033242877,
		-0.622676046417018,
		-0.425003653867738,
		-0.817773072626930,
		0.152418761326014,
		0.366726486589306,
		0.093186229180646,
		-0.148542316257624,
		0.288885562862673,
	};
	
	ARWeightedMovingAverageFilter *filter = [[ARWeightedMovingAverageFilter alloc] initWithWindowSize:1];
	for (int i = 0; i < sampleCount; ++i) {
		// Fetch variables.
		ARFilterValue input = inputs[i];
		double weight = weights[i];
		ARFilterValue correctOutput = correctOutputs[i];
		
		// Process filter.
		ARFilterValue output = [filter filterWithInput:input weight:weight];
		
		// Check value.
		GHAssertEqualsWithAccuracy(output, correctOutput, 1e-6, nil);
	}
	[filter release];
}

@end
