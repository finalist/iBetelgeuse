//
//  ARFeatureView.m
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

#import "ARFeatureView.h"
//#import "ARImageFeatureView.h"
#import "ARTextFeatureView.h"
#import "ARTextFeature.h"
#import "ARSpatialStateManager.h"
#import "ARLocation.h"
#import "ARPoint3D.h"
#import "ARTransform3D.h"

@class ARTextFeature;


@implementation ARFeatureView

- (ARFeature *)feature {
	NSAssert(NO, @"Expected implementation in subclass of this abstract class.");
	return nil;
}

+ (ARFeatureView *)viewForFeature:(ARFeature *)feature {
	//	if ([[feature class] isSubclassOfClass:ARImageFeature]) {
	//		return [[[ARImageFeatureView alloc] initWithFeature:(ARImageFeature *)feature] autorelease];
	//	}
	//	else ...
	if ([feature isKindOfClass:[ARTextFeature class]]) {
		return [[[ARTextFeatureView alloc] initWithFeature:(ARTextFeature *)feature] autorelease];
	} else {
		DebugLog(@"Unknown feature type: %@", [feature class]);
		return nil;
	}
}

- (void)updateWithSpatialState:(ARSpatialStateManager *)spatialState usingRelativeAltitude:(BOOL)useRelativeAltitude {
	// This function uses ECEF coordinates for all variables unless specified otherwise.
	ARPoint3D featurePosition = [[[self feature] location] ECEFCoordinate];
	ARPoint3D devicePosition = [spatialState locationAsECEFCoordinate];
	ARPoint3D upDirection = ARPoint3DNormalize(devicePosition);

	ARPoint3D offsetInENUCoordinates = [[self feature] offset];
	if (useRelativeAltitude)
		offsetInENUCoordinates.z += [spatialState altitude];
	ARPoint3D offset = ARTransform3DNonhomogeneousVectorMatrixMultiply(offsetInENUCoordinates, [spatialState ENUToECEFSpaceTransform]);
	featurePosition = ARPoint3DAdd(featurePosition, offset);

	[[self layer] setPosition:CGPointZero];
	[[self layer] setTransform:CATransform3DConcat(CATransform3DMakeScale(1., -1., 1.), ARTransform3DLookAt(featurePosition, devicePosition, upDirection, ARPoint3DCreate(0., 0., 1.)))]; // Invert the Y axis because the view Y axis increases to the bottom, not to the top.
}

@end
