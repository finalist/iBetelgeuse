//
//  ARSphericalMovingAverageQuaternionFilterTest.m
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


#import "ARSphericalMovingAverageQuaternionFilterTest.h"
#import "ARSphericalMovingAverageQuaternionFilter.h"


@implementation ARSphericalMovingAverageQuaternionFilterTest

- (void)testConstantInput {
	const int inputCount = 20;
	
	const ARQuaternion inputs[] = {
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
		{0.482150574339783, 0.447776996252703, 0.720383289401084, 0.219258983036950},
	};
	
	const ARQuaternion *correctOutputs = inputs;
	
	ARSphericalMovingAverageQuaternionFilter *filter = [[ARSphericalMovingAverageQuaternionFilter alloc] initWithWindowSize:10];
	for (int i = 0; i < inputCount; ++i) {
		const ARQuaternion input = inputs[i];
		const NSTimeInterval timestamp = 0;
		const ARQuaternion correctOutput = correctOutputs[i];
		
		ARQuaternion output = [filter filterWithInput:input timestamp:timestamp];
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(correctOutput, output, 1e-6), nil);
	}
	
	[filter dealloc];
}

/**
 * Test whether no singularities exist near identity
 */
- (void)testNearIdentity {
	const int inputCount = 20;
	
	const ARQuaternion inputs[] = {
		{0.999999314067966,  -0.000291766867754,   0.000834671509205,   0.000768153086423},
		{0.999999609000598,   0.000560891672884,  -0.000676854587569,   0.000096265517313},
		{0.999999864657623,  -0.000126686699583,   0.000431270749966,  -0.000261993811118},
		{0.999999809738666,  -0.000126890411113,   0.000155477722803,  -0.000583307923392},
		{0.999999577709308,  -0.000901573258561,  -0.000133401989247,  -0.000118113397073},
		{0.999998882824133,  -0.000900735190680,   0.000768484706729,   0.000912391285049},
		{0.999999360013604,  -0.000817799125793,  -0.000213896352355,  -0.000751947685467},
		{0.999999774490669,   0.000188074020476,  -0.000642049549956,  -0.000058473495080},
		{0.999999575619672,  -0.000517831669904,   0.000266667047472,   0.000713792352645},
		{0.999999319198170,   0.000682737739135,   0.000248000939785,  -0.000913218435145},
		{0.999999612149727,   0.000714425251091,  -0.000344116672588,   0.000383250141759},
		{0.999998927699059,   0.000927223407639,   0.000605929982176,   0.000957969906117},
		{0.999999406852228,  -0.000022200414511,   0.000998955124743,  -0.000433463945907},
		{0.999999112634875,  -0.000559379302489,   0.000961955468258,  -0.000732438350070},
		{0.999999503216946,  -0.000547582446288,  -0.000745925745047,   0.000370559184738},
		{0.999999518596917,   0.000073575573606,  -0.000535519450276,   0.000818908717273},
		{0.999999384161653,   0.000524219095588,  -0.000952734479953,   0.000221737828212},
		{0.999999610472674,  -0.000304865580349,   0.000214865137108,   0.000799965281257},
		{0.999999506089915,  -0.000077536442921,  -0.000778380972975,  -0.000613132193289},
		{0.999999814586610,   0.000278647472734,  -0.000185080949927,   0.000508849068629},
	};
	
	const ARQuaternion singularityPoint = {1, 0, 0, 0};
	const double accuracy = 1e-3 + 1e-6;
	
	ARSphericalMovingAverageQuaternionFilter *filter = [[ARSphericalMovingAverageQuaternionFilter alloc] initWithWindowSize:5];
	for (int i = 0; i < inputCount; ++i) {
		const ARQuaternion input = inputs[i];
		const NSTimeInterval timestamp = 0;
		
		ARQuaternion output = [filter filterWithInput:input timestamp:timestamp];
		
		ARQuaternion correctOutput;
		if (ARQuaternionDotProduct(output, singularityPoint) < 0) {
			correctOutput = ARQuaternionNegate(correctOutput);
		} else {
			correctOutput = singularityPoint;
		}
		
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(correctOutput, input, accuracy), @"The test filter values are inconsistent.");
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(correctOutput, output, accuracy), nil);
	}
	
	[filter dealloc];
}

/**
 * Test whether no singularities exist at a 180 degree angle.
 */
- (void)testNear180Degrees {
	const int inputCount = 20;
	
	const ARQuaternion inputs[] = {
		{0.000565101020085,  -0.000807328659370,  -0.999999512767501,   0.000057844904473},
		{0.000408931406090,   0.000817051394937,   0.999999507056734,  -0.000388700929637},
		{0.000696308186288,   0.000494393626205,   0.999999469943074,   0.000575189902553},
		{0.000695820793757,   0.000478976813143,  -0.999999639460948,   0.000086559861291},
		{0.000569709002023,  -0.000379275560207,  -0.999999683761932,   0.000405040416218},
		{0.000458336632329,  -0.000736338085281,   0.999999207202214,  -0.000912868390800},
		{0.000544378352023,  -0.000752998005677,   0.999999562171873,   0.000110915625691},
		{0.000357953351431,  -0.000618193923252,   0.999999401063151,   0.000829203841734},
		{0.000659123041868,   0.000708535191576,  -0.999999139872163,  -0.000885318943429},
		{0.000644364224514,  -0.000170087187066,  -0.999999744417675,   0.000258900906028},
		{0.000141365623287,   0.000853276150984,  -0.999999450523748,   0.000592357807510},
		{0.000143659230622,  -0.000644652256638,  -0.999999708784495,   0.000382382554361},
		{0.000427963352801,   0.000445805840075,   0.999999761192940,   0.000309384201687},
		{0.000398266783537,  -0.000851715359480,  -0.999999158692308,   0.000893632582503},
		{0.000592515782007,   0.000014722800478,  -0.999999823538830,   0.000040380629297},
		{0.000116821833178,   0.000309765652334,   0.999999533306702,  -0.000907625626813},
		{0.000107568704136,   0.000780246430178,   0.999999326181141,   0.000852808153745},
		{0.000068675171115,   0.000077051135301,   0.999999823012908,   0.000585936000151},
		{0.000441921473519,  -0.000435589521129,   0.999999656203038,  -0.000550055438856},
		{0.000350750335999,  -0.000951914219316,  -0.999999142313879,   0.000828374932001},
	};
	
	const ARQuaternion singularityPoint = {0, 0, 1., 0};
	const double accuracy = 1e-3 + 1e-6;
	
	ARSphericalMovingAverageQuaternionFilter *filter = [[ARSphericalMovingAverageQuaternionFilter alloc] initWithWindowSize:5];
	for (int i = 0; i < inputCount; ++i) {
		const ARQuaternion input = inputs[i];
		const NSTimeInterval timestamp = 0;
		
		ARQuaternion output = [filter filterWithInput:input timestamp:timestamp];
		
		ARQuaternion correctOutput;
		if (ARQuaternionDotProduct(output, singularityPoint) < 0) {
			correctOutput = ARQuaternionNegate(correctOutput);
		} else {
			correctOutput = singularityPoint;
		}
		
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(correctOutput, input, accuracy), @"The test filter values are inconsistent.");
		GHAssertTrue(ARQuaternionEqualsWithAccuracy(correctOutput, output, accuracy), nil);
	}
	
	[filter dealloc];
}

@end
