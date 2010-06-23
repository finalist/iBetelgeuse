//
//  ARTextOverlay.h
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

#import "AROverlay.h"


/**
 * Value that can be used to indicate an undefined width.
 */
extern const CGFloat ARTextOverlayWidthUndefined;


/**
 * Represents a text overlay in a Gamaray dimension.
 */
@interface ARTextOverlay : AROverlay {
@private
	NSString *text;
	CGFloat width;
}

/**
 * The text that should be displayed, may be nil or empty.
 */
@property(nonatomic, readonly, copy) NSString *text;

/**
 * The width of the text. If the text doesn't fit in this width, it should be wrapped. Must either be ARTextOverlayWidthUndefined or strictly positive.
 */
@property(nonatomic, readonly) CGFloat width;

@end
