//
//  ARViewUtil.m
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

#import "ARViewUtil.h"


// Per Apple's iPhone Human Interface Guidelines
const CGFloat ARMinimumTouchTargetSize = 44.f;


CGRect ARRectGrowToTouchTarget(CGRect rect) {
	return CGRectInset(rect,
					   roundf(MIN(rect.size.width  - ARMinimumTouchTargetSize, 0.f) / 2.f),
					   roundf(MIN(rect.size.height - ARMinimumTouchTargetSize, 0.f) / 2.f)
					   );
}
