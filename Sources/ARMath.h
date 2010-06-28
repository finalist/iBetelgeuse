//
//  ARMath.h
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
//  See http://gcc.gnu.org/onlinedocs/gcc/Typeof.html for more info about
//  the syntax used in this file.

#import <Foundation/Foundation.h>


/**
 * Returns the minimum of the given values. This macro operates on any type and evaluates its arguments only once.
 *
 * @param a The first value.
 * @param b The second value.
 *
 * @return The minimum of a and b.
 */
#define ARMin(a, b) \
	({ \
		__typeof__ (a) _a = (a); \
		__typeof__ (b) _b = (b); \
		MIN(_a, _b); \
	})

/**
 * Returns the maximum of the given values. This macro operates on any type and evaluates its arguments only once.
 *
 * @param a The first value.
 * @param b The second value.
 *
 * @return The maximum of a and b.
 */
#define ARMax(a, b) \
	({ \
		__typeof__ (a) _a = (a); \
		__typeof__ (b) _b = (b); \
		MAX(_a, _b); \
	})

/**
 * Clamps the given value in between the given lower and upper bound and returns the result. This macro operates on any type and evaluates its arguments only once.
 *
 * @param v The value to clamp.
 * @param l The lower bound.
 * @param u The upper bound.
 *
 * @return The value v clamped between l and u.
 */
#define ARClamp(v, l, u) \
	({ \
		__typeof__ (v) _v = (v); \
		__typeof__ (l) _l = (l); \
		__typeof__ (u) _u = (u); \
		MAX(_l, MIN(_v, _u)); \
	})
