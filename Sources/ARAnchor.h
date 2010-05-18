//
//  ARAnchor.h
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

/**
 * An anchor of an object is given as a point in unit coordinate space.
 */
typedef CGPoint ARAnchor;

static inline ARAnchor ARAnchorMake(CGFloat x, CGFloat y) {
	return CGPointMake(x, y);
}

/**
 * Returns the anchor represented by the given Gamaray XML string, which is one of TL, TC, TR, CL, CC, CR, BL, BC and BR.
 *
 * @param string The string to parse. May not be nil.
 * @param valid Upon return of this method, the referenced variable will indicate whether the given string was valid. May be NULL if this value is not needed.
 *
 * @return The anchor, or (0.5, 0.5) if the given string was not valid.
 */
ARAnchor ARAnchorMakeWithXMLString(NSString *string, BOOL *valid);
