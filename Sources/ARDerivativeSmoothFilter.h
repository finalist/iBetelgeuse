//
//  ARDerivativeSmoothFilter.h
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


#import "ARFilter.h"
#import "ARDerivativeFilter.h"
#import "ARMovingAverageFilter.h"


@interface ARDerivativeSmoothFilter : ARFilter {
@private
	ARDerivativeFilter *derivativeFilter;
	ARMovingAverageFilter *derivativeAverageFilter;
	ARFilter *inputAverageFilter;
	ARFilterValue baseCorrectionFactor;
	ARFilterValue correctionFactorDerivativeGain;
	ARFilterValue lastOutput;
	NSTimeInterval lastTimestamp;
	int sampleCount;
}

- (id)initWithBaseCorrectionFactor:(ARFilterValue)aBaseCorrectionFactor correctionFactorDerivativeGain:(ARFilterValue)aCorrectionFactorDerivativeGain derivativeAverageWindowSize:(ARFilterValue)aDerivativeAverageWindowSize;

@end


@interface ARDerivativeSmoothFilterFactory : ARFilterFactory {
@private
	ARFilterValue baseCorrectionFactor;
	ARFilterValue correctionFactorDerivativeGain;
	int derivativeAverageWindowSize;
}

- (id)initWithBaseCorrectionFactor:(ARFilterValue)aBaseCorrectionFactor correctionFactorDerivativeGain:(ARFilterValue)aCorrectionFactorDerivativeGain derivativeAverageWindowSize:(ARFilterValue)aDerivativeAverageWindowSize;

@end