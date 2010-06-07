//
//  ARPoint3D.h
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

#import <Foundation/Foundation.h>


typedef struct {
	double x;
	double y;
	double z;
} ARPoint3D;


typedef enum {
	ARPoint3DCoordinateX = 0,
	ARPoint3DCoordinateY,
	ARPoint3DCoordinateZ
} ARPoint3DCoordinate;


const ARPoint3D ARPoint3DZero;


static inline ARPoint3D ARPoint3DCreate(double x, double y, double z) {
	ARPoint3D result = {x, y, z};
	return result;
}

/**
 * Determines whether two doubles represent the same real value.
 * No epsilon is used, so use caution when applying to values that may
 * be affected by floating point errors.
 *
 * @param a first point to compare
 * @param a second point to compare
 * @return YES if the points are equal, NO otherwise.
 */
static inline BOOL ARPoint3DEquals(ARPoint3D a, ARPoint3D b) {
	return
		a.x == b.x &&
		a.y == b.y &&
		a.z == b.z;
}

static inline double ARPoint3DGetCoordinate(ARPoint3D point, ARPoint3DCoordinate coordinate) {
	NSCAssert(coordinate >= 0 && coordinate <= 2, @"Unexpected coordinate.");
	
	return ((double *)&point)[coordinate];
}

static inline void ARPoint3DSetCoordinate(ARPoint3D *point, ARPoint3DCoordinate coordinate, double value) {
	NSCAssert(coordinate >= 0 && coordinate <= 2, @"Unexpected coordinate.");
	
	((double *)point)[coordinate] = value;
}

/**
 * Computes the dot product of a and b.
 * 
 * @param a first point
 * @param b second point
 * @param The result of "a <dot> b".
 */
static inline double ARPoint3DDotProduct(ARPoint3D a, ARPoint3D b) {
	return
		a.x * b.x +
		a.y * b.y +
		a.z * b.z;
}

/**
 * Computes the cross product of a and b, assuming a right handed coordinate
 * system.
 * 
 * @param a first point
 * @param b second point
 * @param The result of "a <cross> b".
 */
static inline ARPoint3D ARPoint3DCrossProduct(ARPoint3D a, ARPoint3D b) {
	ARPoint3D result = {
		a.y*b.z - a.z*b.y,
		a.z*b.x - a.x*b.z,
		a.x*b.y - a.y*b.x,
	};
	return result;
}

/**
 * Computes the length of the vector from the origin to this point.
 * 
 * @param the point
 * @return the length of the vector "|point|"
 */
static inline double ARPoint3DLength(ARPoint3D point) {
	return sqrt(ARPoint3DDotProduct(point, point));
}

/**
 * Adds the x, y, and z components of a point to another point.
 * 
 * @param a first point
 * @param b second point
 * @return the resulting point "a + b"
 */
static inline ARPoint3D ARPoint3DAdd(ARPoint3D a, ARPoint3D b) {
	ARPoint3D result = {
		a.x + b.x,
		a.y + b.y,
		a.z + b.z,
	};
	return result;
}

/**
 * Subtracts the x, y, and z components of a point from another point.
 * 
 * @param a first point
 * @param b second point
 * @return the resulting point "a - b"
 */
static inline ARPoint3D ARPoint3DSubtract(ARPoint3D a, ARPoint3D b) {
	ARPoint3D result = {
		a.x - b.x,
		a.y - b.y,
		a.z - b.z,
	};
	return result;
}

/**
 * Multiplies the x, y, and z components of a point by a scalar.
 * 
 * @param point the vector to scale
 * @param scale the scale factor
 * @return the resulting point "a * scale"
 */
static inline ARPoint3D ARPoint3DScale(ARPoint3D point, double scale) {
	ARPoint3D result = {
		point.x * scale,
		point.y * scale,
		point.z * scale,
	};
	return result;
}

/**
 * Normalize the vector to unit length. This is equivalent to scaling with a
 * factor of 1/|point|
 * 
 * @param point the point to be normalized
 * @return the normalized point
 */
static inline ARPoint3D ARPoint3DNormalize(ARPoint3D point) {
	return ARPoint3DScale(point, 1. / ARPoint3DLength(point));
}
