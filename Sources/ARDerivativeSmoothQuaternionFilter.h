//
//  ARDerivativeSmoothQuaternionFilter.h
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


#import "ARQuaternionFilter.h"

@class ARFilter;
@class ARWeightedMovingAverageQuaternionFilter;


/**
 * Instead of smoothening the input signal, this filter smoothens the derivative
 * of the signal. Due to the derivative, smoothing, and reintegration steps, the
 * output value may diverge from the real value. A correction factor is used to
 * avoid this behaviour. The estimated value is corrected with the input value,
 * with exponential convergence (the correction 'speed' is proportional to the
 * difference between input and estimate).
 *
 * This works under the assumption that the derivative is
 * continuous and changes relatively slowly. Under these assumptions, this
 * filter should stay closer to the actual function value than filters that do
 * not use the derivative, but may cause a slight overshoot.
 *
 * Since this is a quaternion filter, instead of taking the derivative of the
 * quaternion directly (which does not have to be continuous), we compute the
 * anglar velocity and smoothen that. For the same reason, we use the spherical
 * moving average, rather than the moving average of the quaternion's
 * components.
 *
 * Several methods are used to improve this filter:
 * - To reduce overshoot and achieve faster convergence,
 *   the correction factor is increased proportionally to the angular velocity.
 *   correctionFactorDerivativeGain controls this.
 * - A stabilizer is added, to dampen small derivatives. This causes a slight
 *   delay between movement of the device and filter response, especially for
 *   slow movements, but reduces the jitter caused by noise.
 * - the correction factor is not based on the last sample, but on the average
 *   of the last few samples. The amount of samples for this filter is
 *   controlled by correctingInputAverageFilter
 */
@interface ARDerivativeSmoothQuaternionFilter : ARQuaternionFilter {
	ARWeightedMovingAverageQuaternionFilter *derivativeAverageFilter; // The filter that averages the derivative. Increasing this value gives a smoother value, but a larger delay.
	ARQuaternionFilter *correctingInputAverageFilter; // The filter that averages the corrector value. Increasing this reduces jitter, but gives a larger delay.
	double baseCorrectionFactor; // The correction factor when the derivative is 0. High values cause faster convergence, but also introduce more jitter.
	double correctionFactorDerivativeGain; // The correction factor is increased by this value times the length of the angular velocity. This allows for faster convergence. High values introduce more jitter but faster convergence.
	double stabilizerAngularVelocity; // The maximum angular velocity to cancel out. Increasing this value improves stability, but reduce movement smoothness.
	
	ARQuaternion lastInput;
	ARQuaternion lastOutput;
	NSTimeInterval lastTimestamp;
	int sampleCount;
}

/**
 * Initialize the filter.
 * @param aBaseCorrectionFactor The correction factor when the derivative is 0. High values cause faster convergence, but also introduce more jitter.
 * @param aCorrectionFactorDerivativeGain The correction factor is increased by this value times the length of the angular velocity. This allows for faster convergence. High values introduce more jitter but faster convergence.
 * @param aStabilizerAngularVelocity The maximum angular velocity to cancel out. Increasing this value improves stability, but reduce movement smoothness.
 * @param aDerivativeAverageWindowSize The filter that averages the derivative. Increasing this value gives a smoother value, but a larger delay.
 * @param aCorrectingInputAverageWindowSize The filter that averages the corrector value. Increasing this reduces jitter, but gives a larger delay.
 * @return the initialized filter.
 */
- (id)initWithBaseCorrectionFactor:(double)aBaseCorrectionFactor correctionFactorDerivativeGain:(double)aCorrectionFactorDerivativeGain stabilizerAngularVelocity:(double)aStabilizerAngularVelocity derivativeAverageWindowSize:(int)aDerivativeAverageWindowSize correctingInputAverageWindowSize:(int)aCorrectingInputAverageWindowSize;

@end
