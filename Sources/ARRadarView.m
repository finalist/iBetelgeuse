//
//  ARRadarView.m
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

#import "ARRadarView.h"
#import "ARSpatialStateManager.h"
#import "ARFeature.h"
#import "ARLocation.h"
#import "ARCamera.h"
#import "ARTransform3D.h"


// Default radar view width and height
#define DEFAULT_SIZE 100 // px

// Default radius of displayed features
#define DEFAULT_RADAR_RADIUS 1000 // meters

// Blib width and height
#define BLIB_SIZE 4 // px

// If the device is in horizontal position (the screen normal vector is pointed upwards or downwards within the threshold specified below), the heading is undefined or inaccurate. The view direction will therefore be hidden and the heading determination algorithm will be changed to perform better with almost-parallel up- and view vectors. The high and low threshold values are used to avoid jitter between the two behaviours due to noise if the angle is close to the threshold angle.
#define RADAR_HORIZONAL_THRESHOLD_ANGLE_LOW (15. / 180. * M_PI)
#define RADAR_HORIZONAL_THRESHOLD_ANGLE_HIGH (20. / 180. * M_PI)

// Used as an argument into CGContextAddArc
#define ARC_COUNTERCLOCKWISE 0
#define ARC_CLOCKWISE 1


@implementation ARRadarView

@synthesize features, radius = radarRadius;

- (id)initWithFrame:(CGRect)aFrame {
	if (self = [super initWithFrame:aFrame]) {
		[self setClearsContextBeforeDrawing:YES];
		[self setOpaque:NO];
		
		radarRadius = DEFAULT_RADAR_RADIUS;
		[self setNeedsLayout];
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		extentOfViewGradient = CGGradientCreateWithColorComponents(colorSpace, (CGFloat[]){ 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 0.0 }, (CGFloat[]){ 0.0, 1.0 }, 2);
		CGColorSpaceRelease(colorSpace);
	}
	return self;
}

- (void)dealloc {
	[features release];
	CGGradientRelease(extentOfViewGradient);

	[spatialState release];
	
	[super dealloc];
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.width = DEFAULT_SIZE;
	size.height = DEFAULT_SIZE;
	return size;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect bounds = [self bounds];
	
	// Determine the radius of the radar view, i.e. the circle
	viewRadius = MIN(bounds.size.width, bounds.size.height) / 2.;
	
	// Determine the radius of the area where blibs are displayed
	screenRadius = viewRadius - BLIB_SIZE / 2.;
	
	radarToScreenScale = screenRadius / radarRadius;
	
	[self setNeedsDisplay];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	// Translate so the origin is in the center
	point.x -= viewRadius;
	point.y -= viewRadius;
	
	// Check whether the point is within the view radius
	return point.x * point.x + point.y * point.y <= viewRadius * viewRadius;
}

- (void)updateWithSpatialState:(ARSpatialState *)aSpatialState usingRelativeAltitude:(BOOL)useRelativeAltitude {
	[spatialState release];
	spatialState = [aSpatialState retain];
	
	altitudeOffset = useRelativeAltitude ? [spatialState altitude] : 0.;
		
	ARPoint3D lookVectorInDeviceSpace = ARPoint3DCreate(0., 0., -1.);
	lookVectorInENUSpace = ARTransform3DHomogeneousVectorMatrixMultiply(lookVectorInDeviceSpace, [spatialState DeviceToENUSpaceTransform]);

	[self setNeedsDisplay];
}

- (BOOL)isDeviceInHorizontalPosition {
	float thresholdAngle = wasDeviceInHorizontalPositionBefore ? RADAR_HORIZONAL_THRESHOLD_ANGLE_HIGH : RADAR_HORIZONAL_THRESHOLD_ANGLE_LOW;
	wasDeviceInHorizontalPositionBefore = fabs(lookVectorInENUSpace.z) > cos(thresholdAngle);
	return wasDeviceInHorizontalPositionBefore;
}

- (BOOL)isReliable {
	return lookVectorInENUSpace.z < 0. || ![self isDeviceInHorizontalPosition];
}

- (CATransform3D)ENUToRadarSpaceTransformWithUpDirectionInRadarSpace:(ARPoint3D)upDirectionInRadarSpace  {
	// Map space defines a top-down orthogonal projection oriented so that the y axis matches the looking direction
	// Radar space defines the on-screen radar, so that the top of the displayed radar matches the y axis in map space.
	CATransform3D ENUToRadarTransform;
	
	// If the user looks straight down, the normal method becomes unusable due to the look vector being (almost) parallel to the up vector.
	if ([self isDeviceInHorizontalPosition]) {
		// The normal method is unusable; compute the heading using the look vector instead.
		ARPoint3D yLookVectorInDeviceSpace = ARPoint3DCreate(0, 1, 0);
		ARPoint3D yLookVectorInENUSpace = ARTransform3DHomogeneousVectorMatrixMultiply(yLookVectorInDeviceSpace, [spatialState DeviceToENUSpaceTransform]);
		ENUToRadarTransform = ARTransform3DTranspose(ARTransform3DLookAt(ARPoint3DZero, ARPoint3DCreate(0, 0, 1), yLookVectorInENUSpace, ARPoint3DZero));
	}
	else {
		// Note that the ENU coordinates can be interpreted as having been projected on the XY plane; the Z-axis is ignored.
		ARTransform3D MapToENUTransform = ARTransform3DLookAt(ARPoint3DZero, ARPoint3DCreate(0, 0, 1), lookVectorInENUSpace, ARPoint3DZero);
		ARTransform3D ENUToMapTransform = ARTransform3DTranspose(MapToENUTransform);
		
		ARTransform3D MapToRadarTransform = ARTransform3DLookAt(ARPoint3DZero, ARPoint3DCreate(0, 0, 1), upDirectionInRadarSpace, ARPoint3DZero);
		
		ENUToRadarTransform = CATransform3DConcat(ENUToMapTransform, MapToRadarTransform);
	}
	
	return ENUToRadarTransform;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();

	// Draw the outer radar circle
	CGContextSaveGState(ctx);
	CGContextSetBlendMode(ctx, kCGBlendModeCopy);
	CGContextSetGrayFillColor(ctx, 0.1, 0.5);
	CGContextFillEllipseInRect(ctx, [self bounds]);
	CGContextRestoreGState(ctx);
	
	// Prepare the screen transformation for drawing radar blibs
	CGContextTranslateCTM(ctx, viewRadius, viewRadius);
	CGContextScaleCTM(ctx, 1, -1);
	
	if (spatialState != nil)
	{
		ARPoint3D upDirectionInDeviceSpace = [spatialState upDirectionInDeviceSpace];
		ARPoint3D upDirectionInRadarSpace = ARPoint3DCreate(upDirectionInDeviceSpace.x, upDirectionInDeviceSpace.y, 0);
		
		if ([self isReliable]) {
			// If not looking directly up or down, show the extent of view on the radar
			if (![self isDeviceInHorizontalPosition]) {
				// Determine the extent of view in radar space
				ARPoint3D viewVectorInUnitSpace = upDirectionInRadarSpace;
				double viewDistanceInUnitSpace = ARPoint3DLength(viewVectorInUnitSpace);
				
				// Correct for the cutoff that happens when the device is in the horizontal position (i.e. when isDeviceInHorizontalPosition is YES)
				double horizontalCutoffViewDistanceInUnitSpace = sin(RADAR_HORIZONAL_THRESHOLD_ANGLE_HIGH);
				double correctedViewDistanceInUnitSpace = MAX(0.0, MIN((viewDistanceInUnitSpace - horizontalCutoffViewDistanceInUnitSpace) / (1.0 - horizontalCutoffViewDistanceInUnitSpace), 1.0));
				viewVectorInUnitSpace = ARPoint3DScale(viewVectorInUnitSpace, correctedViewDistanceInUnitSpace / viewDistanceInUnitSpace);
				
				// Determine the extent of view in screen space
				CGPoint viewVectorInScreenSpace = CGPointMake(viewVectorInUnitSpace.x * screenRadius, viewVectorInUnitSpace.y * screenRadius);
				CGFloat viewDistanceInScreenSpace = correctedViewDistanceInUnitSpace * screenRadius;
				CGFloat viewHeading = atan2(viewVectorInUnitSpace.y, viewVectorInUnitSpace.x);
				
				// Determine the angle of view
				CGFloat angleOfView = [[ARCamera sharedCamera] angleOfView];

				// Determine the area indicating the extent of view
				CGContextBeginPath(ctx);
				CGContextMoveToPoint(ctx, 0, 0);
				CGContextAddArc(ctx, 0, 0, viewDistanceInScreenSpace, viewHeading + angleOfView / 2., viewHeading - angleOfView / 2., ARC_CLOCKWISE);
				CGContextClosePath(ctx);
				
//				CGContextSetRGBStrokeColor(ctx, 0, 1, 0, 1);
//				CGContextSetLineWidth(ctx, 2);
//				CGContextStrokePath(ctx);

				// Clip to that area and fill it with a gradient
				CGContextSaveGState(ctx);
				CGContextClip(ctx);
				CGContextDrawLinearGradient(ctx, extentOfViewGradient, CGPointMake(0, 0), viewVectorInScreenSpace, 0);
				CGContextRestoreGState(ctx);
			}

			ARTransform3D ENUToRadarTransform = [self ENUToRadarSpaceTransformWithUpDirectionInRadarSpace:upDirectionInRadarSpace];
			CGContextSetRGBFillColor(ctx, 1.0, 0.35, 0.76, 1.0);
			for (ARFeature *feature in features) {
				// Immediately skip features that should not be displayed on the radar
				if (![feature showInRadar]) {
					continue;
				}

				ARPoint3D featureLocationInECEFSpace = [[feature location] locationInECEFSpace];

				// Also skip features that are on the other side of the plane
				if (ARPoint3DDotProduct(featureLocationInECEFSpace, [spatialState locationInECEFSpace]) < 0) {
					continue;
				}
				
				ARPoint3D featureLocationInEFSpace = ARPoint3DSubtract(featureLocationInECEFSpace, [spatialState EFToECEFSpaceOffset]);
				ARPoint3D featureLocationInENUSpace = ARTransform3DHomogeneousVectorMatrixMultiply(featureLocationInEFSpace, [spatialState EFToENUSpaceTransform]);

				// TODO: We are applying the offset here as well as in ARFeatureView; refactor so that the offset only has to be applied once.
				ARPoint3D offsetInENUSpace = [feature offset];
				offsetInENUSpace.z += altitudeOffset;
				featureLocationInENUSpace = ARPoint3DAdd(featureLocationInENUSpace, [feature offset]);
				
				// Now check whether the feature is still in range
				if (featureLocationInENUSpace.x * featureLocationInENUSpace.x + featureLocationInENUSpace.y * featureLocationInENUSpace.y <= radarRadius * radarRadius) {
					ARPoint3D featureLocationInRadarSpace = ARTransform3DHomogeneousVectorMatrixMultiply(featureLocationInENUSpace, ENUToRadarTransform);
					CGPoint featureLocationInScreenSpace = CGPointMake(featureLocationInRadarSpace.x * radarToScreenScale, featureLocationInRadarSpace.y * radarToScreenScale);
					CGContextFillEllipseInRect(ctx, CGRectMake(featureLocationInScreenSpace.x - BLIB_SIZE / 2., featureLocationInScreenSpace.y - BLIB_SIZE / 2., BLIB_SIZE, BLIB_SIZE));
				}
			}
		}
	}
}

- (void)setRadius:(CGFloat)aRadius {
	if (aRadius <= 0) {
		radarRadius = DEFAULT_RADAR_RADIUS;
	}
	else {
		radarRadius = aRadius;
	}
	
	[self setNeedsLayout];
}

@end
