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
#import "ARImageFeatureView.h"
#import "ARImageFeature.h"
#import "ARTextFeatureView.h"
#import "ARTextFeature.h"
#import "ARSpatialStateManager.h"
#import "ARLocation.h"
#import "ARPoint3D.h"
#import "ARTransform3D.h"


@implementation ARFeatureView

@dynamic feature; // Should be implemented by subclasses

#pragma mark NSObject

- (id)init {
	NSAssert([self class] != [ARFeatureView class], @"Unexpected invocation of invalid initializer; use initWithOverlay: instead.");
	
	return [super init];
}

- (id)initWithFeature:(ARFeature *)feature {
	NSAssert([self class] != [ARFeatureView class], @"Unexpected invocation of abstract method.");
	NSAssert(feature != nil, @"Expected non-nil overlay.");
	
	if (self = [super initWithFrame:CGRectZero]) {
		[[self layer] setAnchorPoint:[feature anchor]];
		
		[self setHidden:YES];
	}
	return self;
}

#pragma mark UIView

- (void)sizeToFit {
	// For this view class, we only want the size our bounds to change (default implementation acts on the frame)
	CGRect bounds = [self bounds];
	bounds.size = [self sizeThatFits:bounds.size];
	[self setBounds:bounds];
}

#pragma mark ARFeatureView

// Consult The Objective-C Programming Language > Allocating and Initializing Objects > Implementing an Initializer > Constraints and Conventions to see why we use id as a return type.
+ (id)viewForFeature:(ARFeature *)feature {
	NSAssert(feature != nil, @"Expected non-nil feature.");
	
	if ([feature isKindOfClass:[ARImageFeature class]]) {
		return [[[ARImageFeatureView alloc] initWithFeature:feature] autorelease];
	}
	else if ([feature isKindOfClass:[ARTextFeature class]]) {
		return [[[ARTextFeatureView alloc] initWithFeature:feature] autorelease];
	}
	else {
		DebugLog(@"Unknown feature type: %@", [feature class]);
		return nil;
	}
}

- (void)updateWithSpatialState:(ARSpatialStateManager *)spatialState usingRelativeAltitude:(BOOL)useRelativeAltitude withDistanceFactor:(float)distanceFactor {
	// This function uses EF coordinates for all variables unless specified otherwise.
	ARPoint3D featurePosition = ARPoint3DSubtract([[[self feature] location] locationInECEFSpace], [spatialState EFToECEFSpaceOffset]);
	ARPoint3D devicePosition = [spatialState locationInEFSpace];
	ARPoint3D upDirection = [spatialState upDirectionInEFSpace];

	ARPoint3D offsetInENUSpace = [[self feature] offset];
	if (useRelativeAltitude)
		offsetInENUSpace.z += [spatialState altitude];
	ARPoint3D offset = ARTransform3DNonhomogeneousVectorMatrixMultiply(offsetInENUSpace, [spatialState ENUToEFSpaceTransform]);
	featurePosition = ARPoint3DAdd(featurePosition, offset);
	
	if (ARPoint3DLength(ARPoint3DSubtract(featurePosition, devicePosition)) == 0.) {
		[self setHidden:YES];
	} else {
		const float scale = ARPoint3DLength(ARPoint3DSubtract(featurePosition, devicePosition)) * distanceFactor; // This is done so that feature coordinates are measured in pixels, not in meters (by undoing screen and perspective transform)
		
		[[self layer] setPosition:CGPointZero];
		[[self layer] setTransform:CATransform3DConcat(CATransform3DMakeScale(scale, -scale, scale), ARTransform3DLookAt(featurePosition, devicePosition, upDirection, ARPoint3DCreate(0., 0., 1.)))]; // Invert the Y axis because the view Y axis increases to the bottom, not to the top.
		[self setHidden:false];
	}
}

@end
