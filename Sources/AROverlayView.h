//
//  AROverlayView.h
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

#import <UIKit/UIKit.h>


@class AROverlay;


/**
 * Abstract superclass for views that display some sort of AROverlay.
 */
@interface AROverlayView : UIControl {
}

/**
 * Creates and returns the right type of view for the given overlay.
 *
 * @param overlay The overlay. May not be nil.
 *
 * @return A view, or nil if no suitable view type was found.
 */
+ (id)viewForOverlay:(AROverlay *)overlay;

/**
 * Abstract method that initializes the receiver with the given overlay. This message may only be sent to subclasses.
 *
 * @param overlay The overlay. May not be nil.
 *
 * @return The receiver.
 */
- (id)initWithOverlay:(AROverlay *)overlay;

/**
 * The overlay that is displayed in this view.
 */
@property(nonatomic, readonly) AROverlay *overlay;

@end
