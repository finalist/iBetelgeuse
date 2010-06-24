//
//  ARRadarView.h
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


@class ARSpatialState, ARRadarBackgroundLayer, ARRadarExtentOfViewLayer, ARRadarBlipsLayer;


/**
 * This view renders the radar.
 */
@interface ARRadarView : UIView {
@private
	CGRect laidOutBounds;
	BOOL deviceHorizontal;

	ARRadarBackgroundLayer *backgroundLayer;
	ARRadarExtentOfViewLayer *extentOfViewLayer;
	ARRadarBlipsLayer *blipsLayer;
}

/**
 * The features that should be displayed on the radar.
 */
@property(nonatomic, readwrite, copy) NSArray *features;

/**
 * The radar's radius in meters.
 */
@property(nonatomic, readwrite) CGFloat radius;

/**
 * Update the blips shown on the radar, as well as the view extent indicator.
 * @param spatialState the new spatial state.
 * @param useRelativeAltitude YES iff relative altitudes are used.
 */
- (void)updateWithSpatialState:(ARSpatialState *)spatialState usingRelativeAltitude:(BOOL)useRelativeAltitude;

@end
