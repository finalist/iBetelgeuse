//
//  ARFeatureView.h
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

@class ARFeature;
@class ARSpatialStateManager;


/**
 * Abstract superclass for views that display some sort of ARFeature.
 */
@interface ARFeatureView : UIView {
}

/**
 * Creates and returns the right type of view for the given feature.
 *
 * @param feature The feature. May not be nil.
 *
 * @return A view, or nil if no suitable view type was found.
 */
+ (id)viewForFeature:(ARFeature *)feature;

/**
 * Abstract method that initializes the receiver with the given feature. This message may only be sent to subclasses.
 *
 * @param feature The feature. May not be nil.
 *
 * @return The receiver.
 */
- (id)initWithFeature:(ARFeature *)feature;

/**
 * The feature that is displayed in this view.
 */
@property(nonatomic, readonly) ARFeature *feature;

/**
 * Updates the position and transform in the ECEF space using the given spatial state.
 */
- (void)updateWithSpatialState:(ARSpatialStateManager *)spatialState usingRelativeAltitude:(BOOL)useRelativeAltitude withDistanceFactor:(float)distanceFactor;

@end
