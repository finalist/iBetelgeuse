//
//  ARQuaternion.h
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

#import "ARPoint3D.h"
#import "ARTransform3D.h"


/**
 * A quaternion, usually a (normalized) rotation or orientation quaternion, but
 * can also be a quaternion representing a point or translation.
 */
typedef struct {
	double w;
	double x;
	double y;
	double z;
} ARQuaternion;

/**
 * Enum containing the indices of each coordinate. ARQuaternionCoordinateCount
 * is used to count the total number of coordinates.
 */
typedef enum {
	ARQuaternionCoordinateIdW,
	ARQuaternionCoordinateIdX,
	ARQuaternionCoordinateIdY,
	ARQuaternionCoordinateIdZ,
	
	ARQuaternionCoordinateCount
} ARQuaternionCoordinateId;


/**
 * A quaternion with every coordinate set to 0.
 */
extern const ARQuaternion ARQuaternionZero;

/**
 * Identify quaternion [1, 0, 0, 0]. Note that quaternions have two identity
 * quaternions, since identity represents the same rotation as -identity.
 */
extern const ARQuaternion ARQuaternionIdentity;

/**
 * The epsilon value used by some quaternion functions.
 */
static const double ARQuaternionEpsilon = 1.e-6;


/**
 * Create a quaternion with the given coordinates.
 * @param w The w coordinate.
 * @param x The x coordinate.
 * @param y The y coordinate.
 * @param z The z coordinate.
 * @return the created quaternion [w, x, y, z].
 */
static inline ARQuaternion ARQuaternionMakeWithCoordinates(double w, double x, double y, double z) {
	ARQuaternion result = {
		w,
		x,
		y,
		z
	};
	return result;
}

/**
 * Create an orientation quaternion from an transformation matrix. The matrix is
 * assumed to be orthogonal and should not have a scaling applied (ie. the axes
 * must be unit length). The translation component of the matrix is ignored.
 * @param transform the input matrix.
 * @return the resulting orientation quaternion.
 */
static inline ARQuaternion ARQuaternionMakeWithTransform(ARTransform3D transform) {
	// http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm (Alternative Method)
	ARQuaternion result;
	result.w = sqrt(ARMax(0., 1. + transform.m11 + transform.m22 + transform.m33)) / 2.;
	result.x = sqrt(ARMax(0., 1. + transform.m11 - transform.m22 - transform.m33)) / 2.;
	result.y = sqrt(ARMax(0., 1. - transform.m11 + transform.m22 - transform.m33)) / 2.;
	result.z = sqrt(ARMax(0., 1. - transform.m11 - transform.m22 + transform.m33)) / 2.;
	result.x = copysign(result.x, transform.m32 - transform.m23);
	result.y = copysign(result.y, transform.m13 - transform.m31);
	result.z = copysign(result.z, transform.m21 - transform.m12);
	return result;
}

/**
 * Convert a point to a quaternion, setting the w coordinate to zero.
 * @param p the input point.
 * @return the resulting quaternion. [0, x, y, z].
 */
static inline ARQuaternion ARQuaternionMakeWithPoint(ARPoint3D p) {
	ARQuaternion result = {
		0,
		p.x,
		p.y,
		p.z
	};
	return result;
}

/**
 * Return a quaternion's coordinate with the given index.
 * @param quaternion the quaternion.
 * @param coordinateId the index of the quaternion's coordinate, must be in
 *                     range [0..4).
 * @return the requested coordinate.
 */
static inline double ARQuaternionGetCoordinate(ARQuaternion quaternion, ARQuaternionCoordinateId coordinateId) {
	NSCAssert(coordinateId >= 0 && coordinateId <= ARQuaternionCoordinateCount, @"Invalid coordinate id.");
	
	return ((double *)&quaternion)[coordinateId];
}

/**
 * Set a quaternion's coordinate with the given index.
 * @param quaternion the quaternion.
 * @param coordinateId the index of the quaternion's coordinate, must be in
 *                     range [0..4).
 * @param value the new value of the coordinate.
 */
static inline void ARQuaternionSetCoordinate(ARQuaternion *quaternion, ARQuaternionCoordinateId coordinateId, double value) {
	NSCAssert(coordinateId >= 0 && coordinateId <= ARQuaternionCoordinateCount, @"Invalid coordinate id.");
	
	((double *)quaternion)[coordinateId] = value;
}

/**
 * Negate each element of a quaternion. For rotation quaternions, this results
 * in a quaternion representing the same rotation.
 * @param q the quaternion to negate.
 * @return the negated quaternion. [-w, -x, -y, -z].
 */
static inline ARQuaternion ARQuaternionNegate(ARQuaternion q) {
	ARQuaternion result = {
		-q.w,
		-q.x,
		-q.y,
		-q.z
	};
	return result;
}

/**
 * Get the quaternion's conjugate. For unit quaternions, this is equal to the
 * quaternion inverse.
 * @param q the quaternion to compute the conjugate of.
 * @result the quaternion's conjugate. [w, -x, -y, -z].
 */
static inline ARQuaternion ARQuaternionConjugate(ARQuaternion q) {
	ARQuaternion result = {
		q.w,
		-q.x,
		-q.y,
		-q.z
	};
	return result;
}

/**
 * Add two quaternions.
 * @param a the first quaternion.
 * @param b the second quaternion.
 * @return the resulting quaternion. a+b.
 */
static inline ARQuaternion ARQuaternionAdd(ARQuaternion a, ARQuaternion b) {
	ARQuaternion result = {
		a.w + b.w,
		a.x + b.x,
		a.y + b.y,
		a.z + b.z,
	};
	return result;
}

/**
 * Subtract one quaternion from another.
 * @param a the first quaternion.
 * @param b the second quaternion.
 * @return the resulting quaternion. a-b.
 */
static inline ARQuaternion ARQuaternionSubtract(ARQuaternion a, ARQuaternion b) {
	ARQuaternion result = {
		a.w - b.w,
		a.x - b.x,
		a.y - b.y,
		a.z - b.z,
	};
	return result;
}

/**
 * Multiply two quaternions. Note that this is not a element-wise operation.
 * @param a the first quaternion.
 * @param b the second quaternion.
 * @return the resulting quaternion. a*b.
 */
static inline ARQuaternion ARQuaternionMultiply(ARQuaternion a, ARQuaternion b) {
	ARQuaternion result = {
		a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z,
		a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y,
		a.w*b.y - a.x*b.z + a.y*b.w + a.z*b.x,
		a.w*b.z + a.x*b.y - a.y*b.x + a.z*b.w
	};
	return result;
}

/**
 * Multiply a quaternion by a scalar.
 * @param q the quaternion.
 * @param s the scalar to multiply by.
 * @return the resulting quaternion. s*q.
 */
static inline ARQuaternion ARQuaternionMultiplyByScalar(ARQuaternion q, double s) {
	ARQuaternion result = {
		q.w * s,
		q.x * s,
		q.y * s,
		q.z * s
	};
	return result;
}

/**
 * Get the value of the component with the largest value.
 * @param quaternion the quaternion.
 * @return the value of the largest component. max(|w|, |x|, |y|, |z|).
 */
static inline double ARQuaternionElementsMaxAbs(ARQuaternion quaternion) {
	double result = ARMax(ARMax(fabs(quaternion.w), fabs(quaternion.x)), ARMax(fabs(quaternion.y), fabs(quaternion.z)));
	return result;
}

/**
 * Compute the dot product of two quaternion.
 * @param a the first quaternion.
 * @param b the second quaternion.
 * @return the dot product.
 */
static inline double ARQuaternionDotProduct(ARQuaternion a, ARQuaternion b) {
	double result = a.w * b.w + a.x * b.x + a.y * b.y + a.z * b.z;
	return result;
}

/**
 * Test whenther two quaternions are exactly equal.
 * @param a the first quaternion.
 * @param b the second quaternion.
 * @return true iff each element of the quaternion is exactly equal. False otherwise.
 */
static inline BOOL ARQuaternionEquals(ARQuaternion a, ARQuaternion b) {
	BOOL result =
		a.w == b.w &&
		a.x == b.x &&
		a.y == b.y &&
		a.z == b.z;
	return result;
}

/**
 * Test whether two quaternions represent the same rotation or orientation,
 * allowing a small error. This function also returns true if one of the
 * quaternions is negated, since for rotation/orientation quaternions, q
 * represents the same rotation as -q.
 * @param a the first quaternion.
 * @param b the second quaternion.
 * @param accuracy the maximum allowed error for each coordinate. If one of the
 *   coordinates differs more than the accuracy, this function returns false.
 * @return true iff all elements are equal within the given accuracy, false
 *   otherwise. If necessary, one of the quaternions will be negated so that
 *   different quaternions representing the same rotation will be detected.
 */
static inline BOOL ARQuaternionEqualsWithAccuracy(ARQuaternion a, ARQuaternion b, double accuracy) {
	if (ARQuaternionDotProduct(a, b) < 0) {
		b = ARQuaternionNegate(b);
	}
	ARQuaternion difference = ARQuaternionSubtract(a, b);
	BOOL result =
		fabs(difference.w) <= accuracy &&
		fabs(difference.x) <= accuracy &&
		fabs(difference.y) <= accuracy &&
		fabs(difference.z) <= accuracy;
	return result;
}

/**
 * Compute the Euclidean norm ("length") of a quaternion.
 * @param q the quaternion.
 * @return the Euclidean norm of q. sqrt(w^2 + x^2 + y^2 + z^2)
 */
static inline double ARQuaternionNorm(ARQuaternion q) {
	double result = sqrt(q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z);
	return result;
}

/**
 * Normalize a quaternion, so that its norm is 1.
 * @param q the quaternion.
 * @return the normalized quaternion, or identity if the quaternion is zero
 *   (within a certain acccuracy). This quaternion is quaranteed to be a unit
 *   quaternion.
 */
static inline ARQuaternion ARQuaternionNormalize(ARQuaternion q) {
	ARQuaternion result;
	double norm = ARQuaternionNorm(q);
	if (norm <= ARQuaternionEpsilon) {
		result = ARQuaternionIdentity;
	} else {
		result = ARQuaternionMultiplyByScalar(q, 1. / norm);
	}
	return result;
}

/**
 * Perform a Spherical Linear intERPolation between two rotation/orientation
 * quaternions, using the shortest great circle distance. The input quaternions
 * should be normalized.
 * @param a the first quaternion.
 * @param b the second quaternion.
 * @param t the interpolation parameter, a value in range [0..1]. If 0, the
 *   result equals a; if 1, the result equals b.
 * @return A normalized quaternion representing the result of the SLERP operation.
 */
static inline ARQuaternion ARQuaternionSLERP(ARQuaternion a, ARQuaternion b, double t) {
	// http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/slerp/index.htm
	ARQuaternion result;
	
	// Calculate angle between the quaternions
	double cosAngle = ARQuaternionDotProduct(a, b);
	if (cosAngle < 0) {
		b = ARQuaternionNegate(b);
		cosAngle = -cosAngle;
	}
	
	// if qa=qb or qa=-qb then theta = 0 and we can return qa
	if (fabs(cosAngle) >= 1. - ARQuaternionEpsilon) {
		result = a;
	} else {
		double angle = acos(cosAngle);
		double sinAngle = sin(angle);
		double ratioA = sin((1. - t) * angle) / sinAngle;
		double ratioB = sin(t * angle) / sinAngle;
		result = ARQuaternionAdd(ARQuaternionMultiplyByScalar(a, ratioA), ARQuaternionMultiplyByScalar(b, ratioB));
		result = ARQuaternionNormalize(result);
	}
	return result;
}

/**
 * Perform a Normalized Linear intERPolation between two rotation/orientation
 * quaternions, using the shortest great circle distance. The input quaternions
 * should be normalized.
 * @param a the first quaternion.
 * @param b the second quaternion.
 * @param t the interpolation parameter, a value in range [0..1]. If 0, the
 *   result equals a; if 1, the result equals b.
 * @return A normalized quaternion representing the result of the NLERP operation.
 */
static inline ARQuaternion ARQuaternionNLERP(ARQuaternion a, ARQuaternion b, double t) {
	// http://www.allegro.cc/forums/thread/599059
	ARQuaternion result;
	
	if (ARQuaternionDotProduct(a, b) < 0) {
		b = ARQuaternionNegate(b);
	}
	
	result = ARQuaternionAdd(ARQuaternionMultiplyByScalar(a, 1. - t), ARQuaternionMultiplyByScalar(b, t));
	result = ARQuaternionNormalize(result);
	return result;
}

/**
 * Transform a quaternion representing a point [0, x, y, z] by another quaternion.
 * @param q the transformation quaternion.
 * @param p the point quaternion. [0, x, y, z].
 * @return the transformed point. q' p q.
 */
static inline ARQuaternion ARQuaternionTransformPointQuaternion(ARQuaternion q, ARQuaternion p) {
	ARQuaternion result = ARQuaternionMultiply(ARQuaternionMultiply(ARQuaternionConjugate(q), p), q);
	return result;
}

/**
 * Transform a point by a quaternion.
 * @param q the transformation quaternion.
 * @param p the point.
 * @return the transformed point. q' [0, px, py, pz] q.
 */
static inline ARPoint3D ARQuaternionTransformPoint(ARQuaternion q, ARPoint3D p) {
	ARQuaternion result = ARQuaternionTransformPointQuaternion(q, ARQuaternionMakeWithPoint(p));
	return ARPoint3DMake(result.x, result.y, result.z);
}

/**
 * Convert a quaternion to a CATransform3D matrix representation.
 * @param q the quaternion.
 * @return the transformation matrix, with an orientation matching the
 *   quaternion's orientation, and with zero translation.
 */
static inline CATransform3D ARQuaternionConvertToMatrix(ARQuaternion q) {
	CATransform3D result = {
		// Row 1
		q.w*q.w + q.x*q.x - q.y*q.y - q.z*q.z,
		2 * (q.x*q.y - q.w*q.z),
		2 * (q.x*q.z + q.w*q.y),
		0,
		
		// Row 2
		2 * (q.x*q.y + q.w*q.z),
		q.w*q.w - q.x*q.x + q.y*q.y - q.z*q.z,
		2 * (q.y*q.z - q.w*q.x),
		0,
		
		// Row 3
		2 * (q.x*q.z - q.w*q.y),
		2 * (q.y*q.z + q.w*q.x),
		q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z,
		0,
		
		// Row 4
		0,
		0,
		0,
		q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z
	};
	return result;
}

/**
 * Convert a quaternion to a point, by ignoring its w component.
 * @param quaternion the quaternion.
 * @return the point. [qx, qy, qz].
 */
static inline ARPoint3D ARQuaternionConvertToPoint(ARQuaternion quaternion) {
	ARPoint3D result = {quaternion.x, quaternion.y, quaternion.z};
	return result;
}

/**
 * Rotate a unit vector in a given direction. The length of dir represents the
 * rotation angle.
 * @param x the quaternion, must be a unit quaternion.
 * @param dir the direction in which to rotate, must be perpendicular to x. Its
 *   length represents the rotation angle.
 * @return the resulting quaternion, may not be normalized.
 */
static inline ARQuaternion ARQuaternionRotateInDirection(ARQuaternion x, ARQuaternion dir)
{
	NSCAssert(fabs(ARQuaternionDotProduct(x, dir)) < ARQuaternionEpsilon, @"Input vectors should be perpendicular.");
	double theta = ARQuaternionNorm(dir);
	if (theta == 0.) {
		return x;
	} else {
		double costheta = cos(theta);
		double sintheta = sin(theta);
		ARQuaternion dirUnit = ARQuaternionMultiplyByScalar(dir, 1./theta);
		x = ARQuaternionAdd(ARQuaternionMultiplyByScalar(x, costheta), ARQuaternionMultiplyByScalar(dirUnit, sintheta));
		NSCAssert(fabs(ARQuaternionNorm(x) - 1.) < ARQuaternionEpsilon, @"Output vector should be normalized.");
		return x;
	}
}

/**
 * Compute the weighted sum of a set of quaternions, by computing a weighted sum
 * of all elements individually.
 * @param n the number of quaternions.
 * @param quaternions the quaternions. Must be of length n.
 * @param weights the weights for each of the quaternions. Must be of length n.
 * @return the resulting sum.
 */
ARQuaternion ARQuaternionWeightedSum(int n, const ARQuaternion quaternions[], const double weights[]);

/**
 * Estimates the spherical weighted average of a set of quaternions. This
 * algorithm may issue unexpected results if the quaternions are not on the same
 * hemisphere.
 * @param n the number of quaternions
 * @param quaternions the quaternions.
 * @param weights the weight for each of the quaternions.
 * @param initialEstimate the initial estimate of the result. Must be a unit vector.
 * @param errorTolerance the desired accuracy.
 * @param maxIterationCount the maximum number of iterations after which the
 *   algorithm is cancelled, returning a estimate that is less accurate than the
 *   tolerance. Used as a safeguard against (semi) infinite loops.
 * @return The spherical weighted average.
 */
ARQuaternion ARQuaternionSphericalWeightedAverageInternal(int n, const ARQuaternion quaternions[], const double weights[], ARQuaternion initialEstimate, double errorTolerance, int maxIterationCount);

/**
 * Estimates the spherical weighted average of a set of quaternions. This
 * algorithm may issue unexpected results if the quaternions are not on the same
 * hemisphere.
 * @param n the number of quaternions
 * @param quaternions the quaternions.
 * @param weights the weight for each of the quaternions.
 * @param errorTolerance the desired accuracy.
 * @param maxIterationCount the maximum number of iterations after which the
 *   algorithm is cancelled, returning a estimate that is less accurate than the
 *   tolerance. Used as a safeguard against (semi) infinite loops.
 * @return The spherical weighted average.
 */
ARQuaternion ARQuaternionSphericalWeightedAverage(int n, const ARQuaternion quaternions[], const double weights[], double errorTolerance, int maxIterationCount);
