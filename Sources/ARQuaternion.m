//
//  ARQuaternion.m
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

#import "ARQuaternion.h"

#define PROFILE_QUATERNION_AVERAGE 0


const ARQuaternion ARQuaternionZero = {0, 0, 0, 0};
const ARQuaternion ARQuaternionIdentity = {1, 0, 0, 0};


ARQuaternion ARQuaternionWeightedSum(int n, const ARQuaternion quaternions[], const double weights[])
{
	ARQuaternion result = ARQuaternionZero;
	for (int i = 0; i < n; ++i) {
		result = ARQuaternionAdd(result, ARQuaternionMultiplyByScalar(quaternions[i], weights[i]));
	}
	
	return result;
}

// This uses the slow method - ComputeMeanSphereSlow described in the paper (for simplicity).
// Unlike in the example code, this inverts vPerp when costheta < 0 (to make quaternions work properly).
// Assumes sum of weights is 1.
// Assumes initialEstimate to be unit length
ARQuaternion ARQuaternionSphericalWeightedAverageInternal(int n, const ARQuaternion quaternions[], const double weights[], ARQuaternion initialEstimate, double errorTolerance, int maxIterationCount) 
{
	// Based on http://math.ucsd.edu/~sbuss/ResearchWeb/spheremean/
	// Samuel R. Buss and Jay Fillmore.
	// "Spherical Averages and Applications to Spherical Splines and Interpolation."
	
	NSCAssert(n > 0, @"at least one quaternion must be given");
	NSCAssert(quaternions, @"expected non-nil argument");
	NSCAssert(weights, @"expected non-nil argument");
	NSCAssert(fabs(ARQuaternionNorm(initialEstimate) - 1) < ARQuaternionEpsilon, @"expected initialEstimate to be a unit quaternion.");
	
#if PROFILE_QUATERNION_AVERAGE
	NSTimeInterval startTime = [[NSDate date] timeIntervalSinceReferenceDate];
#endif
	
	
	//  Step 1: get an initial estimate for the mean.
	ARQuaternion xVec = initialEstimate;
	
	// Step 2: loop, doing non-Newton-style iterations to improve the estimate.
	ARQuaternion *localvv = (ARQuaternion *)malloc(n * sizeof(ARQuaternion));
	
	int iterationNumber = 0;
	for(; iterationNumber < maxIterationCount; ++iterationNumber) {
		// Step 2a: for each vv vector, compute the tangent vector from xVec 
		//		towards the vv vector -- its length is the spherical length 
		//		from xVec to the vv vector.
		
		const ARQuaternion *vi = quaternions;
		for (int i = 0; i < n; ++i, ++vi) {
			double costheta = ARQuaternionDotProduct(*vi, xVec);
			ARQuaternion vPerp = ARQuaternionSubtract(*vi, ARQuaternionMultiplyByScalar(xVec, costheta));
			double sintheta = ARQuaternionNorm(vPerp);
			if (sintheta == 0) {
				localvv[i] = ARQuaternionZero;
			} else {
				double theta = atan2(sintheta, costheta);
				localvv[i] = ARQuaternionMultiplyByScalar(vPerp, theta/sintheta);
			}
		}
		
		// Step 2b: compute the mean of the vectors resulting from Step 2a.
		ARQuaternion xDisp = ARQuaternionWeightedSum(n, localvv, weights);
		
		// Step 2c: rotate xVec in direction xDisp, for new estimate.
		ARQuaternion xVecOld = xVec;
		xVec = ARQuaternionRotateInDirection(xVec, xDisp);
		xVec = ARQuaternionNormalize(xVec);
		
		double error = ARQuaternionElementsMaxAbs(ARQuaternionSubtract(xVec, xVecOld));
		if (error <= errorTolerance) {
			break;
		}
	}
	
	free(localvv);
	
#if PROFILE_QUATERNION_AVERAGE
	NSTimeInterval endTime = [[NSDate date] timeIntervalSinceReferenceDate];
	NSLog(@"Weighted average computated in %d iterations, which took %.3lf seconds.", iterationNumber, endTime - startTime);
#endif
	
	return xVec;
}

ARQuaternion ARQuaternionSphericalWeightedAverage(int n, const ARQuaternion quaternions[], const double weights[], double errorTolerance, int maxIterationCount)
{
	// Based on http://math.ucsd.edu/~sbuss/ResearchWeb/spheremean/
	// Samuel R. Buss and Jay Fillmore.
	// "Spherical Averages and Applications to Spherical Splines and Interpolation."
	
	// Find the coordinate with the max. total absolute value.
	double xAbsSum=0, yAbsSum=0, zAbsSum=0, wAbsSum=0;
	for (int i = 0; i < n; ++i) {
		wAbsSum += fabs(quaternions[i].w);
		xAbsSum += fabs(quaternions[i].x);
		yAbsSum += fabs(quaternions[i].y);
		zAbsSum += fabs(quaternions[i].z);
	}
	
	// Compute initial estimate, based on the largest coordinate.
	ARQuaternion initialEstimate = ARQuaternionZero;
	if (xAbsSum > yAbsSum) {
		if (xAbsSum > zAbsSum) {
			if (xAbsSum > wAbsSum) {
				initialEstimate.x = 1.;
			} else {
				initialEstimate.w = 1.;
			}
		} else {
			if (zAbsSum > wAbsSum) {
				initialEstimate.z = 1.;
			} else {
				initialEstimate.w = 1.;
			}
		}
	}
	else {
		if (yAbsSum > zAbsSum) {
			if (yAbsSum > wAbsSum) {
				initialEstimate.y = 1.;
			}
			else {
				initialEstimate.w = 1.;
			}
		} else {
			if (zAbsSum > wAbsSum) {
				initialEstimate.z = 1.;
			}
			else {
				initialEstimate.w = 1.;
			}
		}
	}
	
	// Correct all quaternions so that they are better comparable.
	ARQuaternion* correctedQuaternions = malloc(n * sizeof(ARQuaternion));
	for (int i = 0; i < n; ++i) {
		correctedQuaternions[i] = ARQuaternionDotProduct(initialEstimate, quaternions[i]) >= 0 ? quaternions[i] : ARQuaternionNegate(quaternions[i]);
	}
	
	// Estimate the weighted quaternion sum by computing the normalized weighted average.
	initialEstimate = ARQuaternionWeightedSum(n, correctedQuaternions, weights);
	initialEstimate = ARQuaternionNormalize(initialEstimate);
	
	// Compute the actual weighted average.
	ARQuaternion result = ARQuaternionSphericalWeightedAverageInternal(n, correctedQuaternions, weights, initialEstimate, errorTolerance, maxIterationCount);
	
	// Free up resources.
	free(correctedQuaternions);
	
	return result;
}