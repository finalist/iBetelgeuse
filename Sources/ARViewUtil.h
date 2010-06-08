//
//  ARViewUtil.h
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

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif


/**
 * The minimum size (applies to both width and height) that a view should be in order for it to be touchable by the user's finger.
 */
extern const CGFloat ARMinimumTouchTargetSize;


/**
 * Grows the given rectangle, if necessary, to make it into a target suitable for touching with a finger on the screen.
 *
 * @param rect A rectangle.
 *
 * @return A rectangle that is equal to or slightly bigger than the given rectangle.
 */
CGRect ARRectGrowToTouchTarget(CGRect rect);
