//
//  ARFeatureContainerView.m
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

#import "ARFeatureContainerView.h"
#import "ARFeatureView.h"
#import "ARCamera.h"
#import "ARSpatialState.h"
#import "ARPoint3D.h"
#import "ARTransform3D.h"


@implementation ARFeatureContainerView

#pragma mark NSObject

- (id)initWithFrame:(CGRect)aFrame {
	if (self = [super initWithFrame:aFrame]) {		
		EFToDeviceSpaceTransform = CATransform3DIdentity;
		
		perspectiveTransform = [[ARCamera currentCamera] perspectiveTransform];

		screenTransform = CATransform3DIdentity;
		distanceFactor = 1.0;
	}
	return self;
}

#pragma mark UIView

- (void)setFrame:(CGRect)frame {
	// Force our bounds to the right origin and size (see setBounds:)
	[self setBounds:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	
	[super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
	// Force the origin of our bounds to the middle
	bounds.origin.x = -roundf(bounds.size.width / 2.f);
	bounds.origin.y = -roundf(bounds.size.height / 2.f);
	[super setBounds:bounds];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect bounds = [self bounds];
	
	// Invert the y-axis because the view y-axis extends towards the bottom, not the top, of the device
	CGFloat size = MAX(bounds.size.width, bounds.size.height);
	screenTransform = CATransform3DMakeScale(size / 2., -size / 2., 1.);
	invertedScreenTransform = CATransform3DInvert(screenTransform);
	
	// Factor that is used to keep feature views the same apparent size by undoing the view and projection transformations 
	distanceFactor = 2. / size / [[ARCamera currentCamera] distanceToViewPlane];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	// Convert the point to a point on the view plane
	ARPoint3D pointOnViewPlaneInDeviceSpace = ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3DCreate(point.x, point.y, 0), invertedScreenTransform);
	pointOnViewPlaneInDeviceSpace.z = -[[ARCamera currentCamera] distanceToViewPlane];

	for (UIView *featureView in [self subviews]) {
		CATransform3D DeviceToObjectSpaceTransform = CATransform3DInvert(CATransform3DConcat([[featureView layer] transform], EFToDeviceSpaceTransform));

		// Determine two points on the imaginary ray that originates from the camera and passes through the point on the view plane
		ARPoint3D cameraInObjectSpace = ARTransform3DHomogeneousVectorMatrixMultiply(ARPoint3DZero, DeviceToObjectSpaceTransform);
		ARPoint3D pointOnViewPlaneInObjectSpace = ARTransform3DHomogeneousVectorMatrixMultiply(pointOnViewPlaneInDeviceSpace, DeviceToObjectSpaceTransform);

		// The above ray can be defined by the line L = L_a + t * (L_b - L_a). The t calculated below determines
		// the exact point where this line intersects the plane given by the feature view
		CGFloat t = cameraInObjectSpace.z / (cameraInObjectSpace.z - pointOnViewPlaneInObjectSpace.z);
		
		// When t is negative, the object is behind us (when t is NaN or Inf the object plane is probably parallel to the 'ray' resulting in division by zero)
		if (isfinite(t) && t > 0) {
			ARPoint3D pointOnObjectPlaneInObjectSpace = ARPoint3DAdd(cameraInObjectSpace, ARPoint3DScale(ARPoint3DSubtract(pointOnViewPlaneInObjectSpace, cameraInObjectSpace), t));
			NSAssert(fabs(pointOnObjectPlaneInObjectSpace.z) < 1e-4, @"Expected zero z coordinate, by definition.");
			
			// Convert the point from object space to the actual space used by the feature view
			CGRect featureBounds = [featureView bounds];
			CGPoint featureAnchor = [[featureView layer] anchorPoint];
			CGPoint pointInFeatureSpace;
			pointInFeatureSpace.x = featureBounds.origin.x + featureAnchor.x * featureBounds.size.width + pointOnObjectPlaneInObjectSpace.x;
			pointInFeatureSpace.y = featureBounds.origin.y + featureAnchor.y * featureBounds.size.height + pointOnObjectPlaneInObjectSpace.y;
			
			// Do the actual hit-testing
			if ([featureView pointInside:pointInFeatureSpace withEvent:event]) {
				UIView *hitView = [featureView hitTest:pointInFeatureSpace withEvent:event];
				if (hitView != nil) {
					return hitView;
				}
			}
		}
	}
	
	return nil;
}

#pragma mark ARFeatureContainerView

- (void)updateWithSpatialState:(ARSpatialState *)spatialState usingRelativeAltitude:(BOOL)relativeAltitude {
	EFToDeviceSpaceTransform = CATransform3DConcat([spatialState EFToENUSpaceTransform], [spatialState ENUToDeviceSpaceTransform]);
	
	CATransform3D sublayerTransform = EFToDeviceSpaceTransform;
	sublayerTransform = CATransform3DConcat(sublayerTransform, perspectiveTransform);
	sublayerTransform = CATransform3DConcat(sublayerTransform, screenTransform);

	// Disable implicit animations
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	[[self layer] setSublayerTransform:sublayerTransform];
	
	for (ARFeatureView *featureView in [self subviews]) {
		NSAssert([featureView isKindOfClass:[ARFeatureView class]], nil);
		[featureView updateWithSpatialState:spatialState usingRelativeAltitude:relativeAltitude withDistanceFactor:distanceFactor];
	}
	
	[CATransaction commit];
}

@end
