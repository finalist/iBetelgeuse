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


typedef struct {
	double w;
	double x;
	double y;
	double z;
} ARQuaternion;

typedef enum {
	ARQuaternionCoordinateIdW,
	ARQuaternionCoordinateIdX,
	ARQuaternionCoordinateIdY,
	ARQuaternionCoordinateIdZ,
	
	ARQuaternionCoordinateCount
} ARQuaternionCoordinateId;


extern const ARQuaternion ARQuaternionZero;
extern const ARQuaternion ARQuaternionIdentity;

static const double ARQuaternionEpsilon = 1.e-6;


static inline ARQuaternion ARQuaternionMakeWithCoordinates(double w, double x, double y, double z) {
	ARQuaternion result = {
		w,
		x,
		y,
		z
	};
	return result;
}

static inline ARQuaternion ARQuaternionMakeWithTransform(ARTransform3D transform) {
	// http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm (Alternative Method)
	ARQuaternion result;
	result.w = sqrt(fmax(0., 1. + transform.m11 + transform.m22 + transform.m33)) / 2.;
	result.x = sqrt(fmax(0., 1. + transform.m11 - transform.m22 - transform.m33)) / 2.;
	result.y = sqrt(fmax(0., 1. - transform.m11 + transform.m22 - transform.m33)) / 2.;
	result.z = sqrt(fmax(0., 1. - transform.m11 - transform.m22 + transform.m33)) / 2.;
	result.x = copysign(result.x, transform.m32 - transform.m23);
	result.y = copysign(result.y, transform.m13 - transform.m31);
	result.z = copysign(result.z, transform.m21 - transform.m12);
	return result;
}

static inline ARQuaternion ARQuaternionMakeWithPoint(ARPoint3D p) {
	ARQuaternion result = {
		0,
		p.x,
		p.y,
		p.z
	};
	return result;
}

static inline double ARQuaternionGetCoordinate(ARQuaternion quaternion, ARQuaternionCoordinateId coordinateId) {
	NSCAssert(coordinateId >= 0 && coordinateId <= ARQuaternionCoordinateCount, @"Invalid coordinate id.");
	
	return ((double *)&quaternion)[coordinateId];
}

static inline void ARQuaternionSetCoordinate(ARQuaternion *quaternion, ARQuaternionCoordinateId coordinateId, double value) {
	NSCAssert(coordinateId >= 0 && coordinateId <= ARQuaternionCoordinateCount, @"Invalid coordinate id.");
	
	((double *)quaternion)[coordinateId] = value;
}

static inline ARQuaternion ARQuaternionNegate(ARQuaternion q) {
	ARQuaternion result = {
		-q.w,
		-q.x,
		-q.y,
		-q.z
	};
	return result;
}

static inline ARQuaternion ARQuaternionConjugate(ARQuaternion q) {
	ARQuaternion result = {
		q.w,
		-q.x,
		-q.y,
		-q.z
	};
	return result;
}

static inline ARQuaternion ARQuaternionAdd(ARQuaternion a, ARQuaternion b) {
	ARQuaternion result = {
		a.w + b.w,
		a.x + b.x,
		a.y + b.y,
		a.z + b.z,
	};
	return result;
}

static inline ARQuaternion ARQuaternionSubtract(ARQuaternion a, ARQuaternion b) {
	ARQuaternion result = {
		a.w - b.w,
		a.x - b.x,
		a.y - b.y,
		a.z - b.z,
	};
	return result;
}

static inline ARQuaternion ARQuaternionMultiply(ARQuaternion a, ARQuaternion b) {
	ARQuaternion result = {
		a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z,
		a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y,
		a.w*b.y - a.x*b.z + a.y*b.w + a.z*b.x,
		a.w*b.z + a.x*b.y - a.y*b.x + a.z*b.w
	};
	return result;
}

static inline ARQuaternion ARQuaternionMultiplyByScalar(ARQuaternion q, double s) {
	ARQuaternion result = {
		q.w * s,
		q.x * s,
		q.y * s,
		q.z * s
	};
	return result;
}

static inline double ARQuaternionElementsMaxAbs(ARQuaternion quaternion) {
	double result = MAX(MAX(fabs(quaternion.w), fabs(quaternion.x)), MAX(fabs(quaternion.y), fabs(quaternion.z)));
	return result;
}

static inline double ARQuaternionDotProduct(ARQuaternion a, ARQuaternion b) {
	double result = a.w * b.w + a.x * b.x + a.y * b.y + a.z * b.z;
	return result;
}

static inline BOOL ARQuaternionEquals(ARQuaternion a, ARQuaternion b) {
	BOOL result =
		a.w == b.w &&
		a.x == b.x &&
		a.y == b.y &&
		a.z == b.z;
	return result;
}

static inline BOOL ARQuaternionEqualsWithAccuracy(ARQuaternion a, ARQuaternion b, double accuracy) {
	if (a.w * b.w < 0) {
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

static inline double ARQuaternionNorm(ARQuaternion q) {
	double result = sqrt(q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z);
	return result;
}

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

static inline ARQuaternion ARQuaternionSLERP(ARQuaternion a, ARQuaternion b, double t) {
	// http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/slerp/index.htm
	ARQuaternion result;
	
	// Calculate angle between the quaternions
	double cosAngle = a.w * b.w + a.x * b.x + a.y * b.y + a.z * b.z;
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

static inline ARQuaternion ARQuaternionNLERP(ARQuaternion a, ARQuaternion b, double t) {
	// http://www.allegro.cc/forums/thread/599059
	ARQuaternion result;
	
	double cosAngle = a.w * b.w + a.x * b.x + a.y * b.y + a.z * b.z;
	if (cosAngle < 0) {
		b = ARQuaternionNegate(b);
		cosAngle = -cosAngle;
	}
	
	result = ARQuaternionAdd(ARQuaternionMultiplyByScalar(a, 1. - t), ARQuaternionMultiplyByScalar(b, t));
	result = ARQuaternionNormalize(result);
	return result;
}

static inline ARQuaternion ARQuaternionTransformPointQuaternion(ARQuaternion q, ARQuaternion p) {
	ARQuaternion result = ARQuaternionMultiply(ARQuaternionMultiply(ARQuaternionConjugate(q), p), q);
	return result;
}

static inline ARPoint3D ARQuaternionTransformPoint(ARQuaternion q, ARPoint3D p) {
	ARQuaternion result = ARQuaternionTransformPointQuaternion(q, ARQuaternionMakeWithPoint(p));
	return ARPoint3DCreate(result.x, result.y, result.z);
}

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

static inline ARPoint3D ARQuaternionConvertToPoint(ARQuaternion quaternion) {
	ARPoint3D result = {quaternion.x, quaternion.y, quaternion.z};
	return result;
}

// Rotate unit vector x in the direction of "dir": length of dir is rotation angle.
//		x must be a unit vector.  dir must be perpindicular to x.
// Note: does not necessarily return normalized results.
static inline ARQuaternion ARQuaternionRotateInDirection(ARQuaternion x, ARQuaternion dir)
{
	double theta = ARQuaternionNorm(dir);
	if (theta == 0.) {
		return x;
	} else {
		double costheta = cos(theta);
		double sintheta = sin(theta);
		ARQuaternion dirUnit = ARQuaternionMultiplyByScalar(dir, 1./theta);
		x = ARQuaternionAdd(ARQuaternionMultiplyByScalar(x, costheta), ARQuaternionMultiplyByScalar(dirUnit, sintheta));
		return x;
	}
}

ARQuaternion ARQuaternionWeightedSum(int n, const ARQuaternion quaternions[], const double weights[]);
ARQuaternion ARQuaternionSphericalWeightedAverageInternal(int n, const ARQuaternion quaternions[], const double weights[], ARQuaternion initialEstimate, double tolerance, int maxIterationCount);
ARQuaternion ARQuaternionSphericalWeightedAverage(int n, const ARQuaternion quaternions[], const double weights[], double errorTolerance, int maxIterationCount);
