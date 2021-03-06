//
//  ARTransform3D.m
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

#import "ARTransform3D.h"
#import "ARPoint3D.h"


ARTransform3D ARTransform3DMakeFromAxesAndTranslation(ARPoint3D xAxis, ARPoint3D yAxis, ARPoint3D zAxis, ARPoint3D translation) {
	ARTransform3D result;
	result.m11 = xAxis.x;
	result.m12 = xAxis.y;
	result.m13 = xAxis.z;
	result.m14 = 0.;
	result.m21 = yAxis.x;
	result.m22 = yAxis.y;
	result.m23 = yAxis.z;
	result.m24 = 0.;
	result.m31 = zAxis.x;
	result.m32 = zAxis.y;
	result.m33 = zAxis.z;
	result.m34 = 0.;
	result.m41 = translation.x;
	result.m42 = translation.y;
	result.m43 = translation.z;
	result.m44 = 1.;
	return result;
}

ARTransform3D ARTransform3DMakeFromAxes(ARPoint3D xAxis, ARPoint3D yAxis, ARPoint3D zAxis) {
	return ARTransform3DMakeFromAxesAndTranslation(xAxis, yAxis, zAxis, ARPoint3DZero);
}

BOOL ARTransform3DEqualsWithAccuracy(ARTransform3D a, ARTransform3D b, CGFloat accuracy) {
	BOOL result =
		fabsf(a.m11 - b.m11) <= accuracy &&
		fabsf(a.m12 - b.m12) <= accuracy &&
		fabsf(a.m13 - b.m13) <= accuracy &&
		fabsf(a.m14 - b.m14) <= accuracy &&
		fabsf(a.m21 - b.m21) <= accuracy &&
		fabsf(a.m22 - b.m22) <= accuracy &&
		fabsf(a.m23 - b.m23) <= accuracy &&
		fabsf(a.m24 - b.m24) <= accuracy &&
		fabsf(a.m31 - b.m31) <= accuracy &&
		fabsf(a.m32 - b.m32) <= accuracy &&
		fabsf(a.m33 - b.m33) <= accuracy &&
		fabsf(a.m34 - b.m34) <= accuracy &&
		fabsf(a.m41 - b.m41) <= accuracy &&
		fabsf(a.m42 - b.m42) <= accuracy &&
		fabsf(a.m43 - b.m43) <= accuracy &&
		fabsf(a.m44 - b.m44) <= accuracy;
	return result;
}

ARTransform3D ARTransform3DLookAt(ARPoint3D origin, ARPoint3D target, ARPoint3D upDirection, ARPoint3D alternativeUpDirection) {
	return ARTransform3DLookAtRelative(origin, ARPoint3DSubtract(target, origin), upDirection, alternativeUpDirection);
}

ARTransform3D ARTransform3DLookAtRelative(ARPoint3D origin, ARPoint3D targetDirection, ARPoint3D upDirection, ARPoint3D alternativeUpDirection) {
	NSCAssert(!ARPoint3DEquals(targetDirection, ARPoint3DMake(0., 0., 0.)), nil);
	NSCAssert(!ARPoint3DEquals(upDirection, ARPoint3DMake(0., 0., 0.)), nil);
	
	ARPoint3D zAxis = targetDirection;
	ARPoint3D xAxis = ARPoint3DCrossProduct(upDirection, zAxis);
	if (ARPoint3DLength(xAxis) == 0.)
		xAxis = ARPoint3DCrossProduct(alternativeUpDirection, zAxis);
	ARPoint3D yAxis = ARPoint3DCrossProduct(zAxis, xAxis);
	
	xAxis = ARPoint3DNormalize(xAxis);
	yAxis = ARPoint3DNormalize(yAxis);
	zAxis = ARPoint3DNormalize(zAxis);
	
	return ARTransform3DMakeFromAxesAndTranslation(xAxis, yAxis, zAxis, origin);
}

ARTransform3D ARTransform3DTranspose(ARTransform3D transform) {
	ARTransform3D result;
	result.m11 = transform.m11;
	result.m12 = transform.m21;
	result.m13 = transform.m31;
	result.m14 = transform.m41;
	result.m21 = transform.m12;
	result.m22 = transform.m22;
	result.m23 = transform.m32;
	result.m24 = transform.m42;
	result.m31 = transform.m13;
	result.m32 = transform.m23;
	result.m33 = transform.m33;
	result.m34 = transform.m43;
	result.m41 = transform.m14;
	result.m42 = transform.m24;
	result.m43 = transform.m34;
	result.m44 = transform.m44;
	return result;
}

ARPoint3D ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3D a, ARTransform3D b) {
	double inverseOfSuperfluousCoordinate = 1. / (b.m14 * a.x + b.m24 * a.y + b.m34 * a.z + b.m44);
	ARPoint3D result = {
		(b.m11 * a.x + b.m21 * a.y + b.m31 * a.z + b.m41) * inverseOfSuperfluousCoordinate,
		(b.m12 * a.x + b.m22 * a.y + b.m32 * a.z + b.m42) * inverseOfSuperfluousCoordinate,
		(b.m13 * a.x + b.m23 * a.y + b.m33 * a.z + b.m43) * inverseOfSuperfluousCoordinate,
	};
	return result;
}

ARPoint3D ARTransform3DNonhomogeneousVectorMatrixMultiply(ARPoint3D a, ARTransform3D b) {
	ARPoint3D result = {
		b.m11 * a.x + b.m21 * a.y + b.m31 * a.z,
		b.m12 * a.x + b.m22 * a.y + b.m32 * a.z,
		b.m13 * a.x + b.m23 * a.y + b.m33 * a.z,
	};
	return result;
}

#ifdef DEBUG

NSString *ARTransform3DGetMATLABString(CATransform3D t) {
	return [NSString stringWithFormat:@"[ %14.7f %14.7f %14.7f %14.7f; %14.7f %14.7f %14.7f %14.7f; %14.7f %14.7f %14.7f %14.7f; %14.7f %14.7f %14.7f %14.7f ]", t.m11, t.m12, t.m13, t.m14, t.m21, t.m22, t.m23, t.m24, t.m31, t.m32, t.m33, t.m34, t.m41, t.m42, t.m43, t.m44];
}

#endif
