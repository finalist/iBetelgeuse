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
#import "ARSpatialState.h"
#import "ARFeature.h"
#import "ARLocation.h"
#import "ARCamera.h"
#import "ARTransform3D.h"


// Default radar view width and height
#define DEFAULT_SIZE 100 // px

// Default radius of displayed features
#define DEFAULT_RADIUS 1000 // meters

// Blib width and height
#define BLIB_SIZE 4 // px

// If the device is in horizontal position (the screen normal vector is pointed upwards or downwards within the threshold specified below), the heading is undefined or inaccurate. The view direction will therefore be hidden and the heading determination algorithm will be changed to perform better with almost-parallel up- and view vectors. The high and low threshold values are used to avoid jitter between the two behaviours due to noise if the angle is close to the threshold angle.
#define HORIZONAL_THRESHOLD_ANGLE_LOW (15. / 180. * M_PI)
#define HORIZONAL_THRESHOLD_ANGLE_HIGH (20. / 180. * M_PI)

// Used as an argument into CGContextAddArc
#define ARC_COUNTERCLOCKWISE 0
#define ARC_CLOCKWISE 1


@interface ARRadarView ()

@property(nonatomic, readwrite) CGRect laidOutBounds;
@property(nonatomic, readwrite, getter=isDeviceHorizontal) BOOL deviceHorizontal;

@property(nonatomic, readonly) ARRadarBackgroundLayer *backgroundLayer;
@property(nonatomic, readonly) ARRadarExtentOfViewLayer *extentOfViewLayer;
@property(nonatomic, readonly) ARRadarBlipsLayer *blipsLayer;

@end


@interface ARRadarBackgroundLayer : CALayer {
}

@end


@interface ARRadarExtentOfViewLayer : CALayer {
@private
	CGPoint viewVector;
	
	CGGradientRef gradient;
}

/**
 * A vector in unit coordinate space, where a vector of [0, 1] will result in an upward pointing indicator.
 */
@property(nonatomic, readwrite) CGPoint viewVector;

@property(nonatomic, readonly) CGGradientRef gradient;

@end


@interface ARRadarBlipsLayer : CALayer {
@private
	NSArray *features;
	CGFloat radius;
	ARSpatialState *spatialState;
}

@property(nonatomic, readwrite, copy) NSArray *features;
@property(nonatomic, readwrite) CGFloat radius;
@property(nonatomic, readwrite, retain) ARSpatialState *spatialState;

@end


@implementation ARRadarView

@synthesize laidOutBounds, deviceHorizontal;
@synthesize backgroundLayer, extentOfViewLayer, blipsLayer;

#pragma mark NSObject

- (id)initWithFrame:(CGRect)aFrame {
	if (self = [super initWithFrame:aFrame]) {
		CALayer *layer = [self layer];
		
		backgroundLayer = [[ARRadarBackgroundLayer alloc] init];
		[layer addSublayer:backgroundLayer];
		
		extentOfViewLayer = [[ARRadarExtentOfViewLayer alloc] init];
		[layer addSublayer:extentOfViewLayer];
		
		// We don't want the transform of the blips layer to be animated implicitly
		blipsLayer = [[ARRadarBlipsLayer alloc] init];
		[blipsLayer setActions:[NSDictionary dictionaryWithObject:[NSNull null] forKey:@"transform"]];
		[layer addSublayer:blipsLayer];
	}
	return self;
}

- (void)dealloc {
	[backgroundLayer release];
	[extentOfViewLayer release];
	[blipsLayer release];
	
	[super dealloc];
}

#pragma mark UIView

- (CGSize)sizeThatFits:(CGSize)size {
	size.width = DEFAULT_SIZE;
	size.height = DEFAULT_SIZE;
	return size;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect bounds = [self bounds];
	if (!CGRectEqualToRect(bounds, laidOutBounds)) {
		[backgroundLayer setFrame:bounds];
		[extentOfViewLayer setFrame:bounds];
		[blipsLayer setFrame:bounds];
		
		laidOutBounds = bounds;
	}
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	CGRect bounds = [self bounds];
	
	// Translate so the origin is in the center
	point.x -= bounds.size.width / 2.0;
	point.y -= bounds.size.height / 2.0;
	
	// Check whether the point is within the view radius
	return point.x * point.x + point.y * point.y <= bounds.size.width / 2.0 * bounds.size.width / 2.0;
}

#pragma mark ARRadarView

- (NSArray *)features {
	return [blipsLayer features];
}

- (void)setFeatures:(NSArray *)someFeatures {
	[blipsLayer setFeatures:someFeatures];
}

- (CGFloat)radius {
	return [blipsLayer radius];
}

- (void)setRadius:(CGFloat)aRadius {
	[blipsLayer setRadius:aRadius];
}

- (void)updateWithSpatialState:(ARSpatialState *)spatialState usingRelativeAltitude:(BOOL)useRelativeAltitude {
	// Determine the direction in which the user is facing
	ARPoint3D viewUnitVectorInDeviceSpace = ARPoint3DCreate(0., 0., -1.);
	ARPoint3D viewUnitVectorInENUSpace = ARTransform3DHomogeneousVectorMatrixMultiply(viewUnitVectorInDeviceSpace, [spatialState DeviceToENUSpaceTransform]);
	
	// Determine whether the device is horizontal
	// Note: we use a high and low threshold, so that we don't jump between horizontal/non-horizontal right at the threshold
	CGFloat horizontalThresholdAngle = deviceHorizontal ? HORIZONAL_THRESHOLD_ANGLE_HIGH : HORIZONAL_THRESHOLD_ANGLE_LOW;
	deviceHorizontal = fabs(viewUnitVectorInENUSpace.z) > cos(horizontalThresholdAngle);
	
	// Determine the direction that is up on the radar
	ARPoint3D upDirectionInDeviceSpace = [spatialState upDirectionInDeviceSpace];
	ARPoint3D upUnitVectorInRadarSpace = ARPoint3DNormalize(upDirectionInDeviceSpace);

	// Update the extent of view layer
	if (deviceHorizontal) {
		[extentOfViewLayer setHidden:YES];
	}
	else {
		[extentOfViewLayer setViewVector:CGPointMake(upUnitVectorInRadarSpace.x, upUnitVectorInRadarSpace.y)];
		[extentOfViewLayer setHidden:NO];
	}
	
	// Update the blips layer
	if (deviceHorizontal && viewUnitVectorInENUSpace.z > 0.) {
		[blipsLayer setHidden:YES];
	}
	else {
		ARTransform3D ENUToRadarTransform;
		if (deviceHorizontal) {
			// The normal method (making the transforms) is unusable when the view vector is (almost) parallel to the up vector
			ARPoint3D bearingInDeviceSpace = ARPoint3DCreate(0, 1, 0);
			ARPoint3D bearingInENUSpace = ARTransform3DHomogeneousVectorMatrixMultiply(bearingInDeviceSpace, [spatialState DeviceToENUSpaceTransform]);
			
			ENUToRadarTransform = ARTransform3DLookAt(ARPoint3DZero, ARPoint3DCreate(0, 0, 1), bearingInENUSpace, ARPoint3DZero);
		}
		else {
			// ENU coordinates can be interpreted as having been projected onto the xy plane by ignoring the z-axis
			ARTransform3D MapToENUTransform = ARTransform3DLookAt(ARPoint3DZero, ARPoint3DCreate(0, 0, 1), viewUnitVectorInENUSpace, ARPoint3DZero);

			ARTransform3D MapToRadarTransform = ARTransform3DLookAt(ARPoint3DZero, ARPoint3DCreate(0, 0, 1), [spatialState upDirectionInDeviceSpace], ARPoint3DZero);
			ARTransform3D RadarToMapTransform = ARTransform3DTranspose(MapToRadarTransform);
			
			ENUToRadarTransform = CATransform3DConcat(RadarToMapTransform, MapToENUTransform);
		}
		[blipsLayer setTransform:ENUToRadarTransform];
		[blipsLayer setSpatialState:spatialState];
		[blipsLayer setHidden:NO];
	}
}

@end


@implementation ARRadarBackgroundLayer

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		[self setNeedsDisplay];
		[self setNeedsDisplayOnBoundsChange:YES];
	}
	return self;
}

#pragma mark CALayer

- (void)drawInContext:(CGContextRef)ctx {
	CGRect bounds = [self bounds];
	
	// Draw the radar circle
	CGContextSetGrayFillColor(ctx, 0.1, 0.5);
	CGContextFillEllipseInRect(ctx, bounds);
	
	// Draw the little dot at the center of the circle
	CGContextSetGrayFillColor(ctx, 1.0, 0.5);
	CGContextFillEllipseInRect(ctx, CGRectMake(CGRectGetMidX(bounds) - 1.0, CGRectGetMidY(bounds) - 1.0, 2.0, 2.0));
}

@end


@implementation ARRadarExtentOfViewLayer

@synthesize viewVector, gradient;

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		[self setNeedsDisplay];
		[self setNeedsDisplayOnBoundsChange:YES];
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		gradient = CGGradientCreateWithColorComponents(colorSpace, (CGFloat[]){ 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 0.0 }, (CGFloat[]){ 0.0, 1.0 }, 2);
		CGColorSpaceRelease(colorSpace);
	}
	return self;
}

- (void)dealloc {
	CGGradientRelease(gradient);
	
	[super dealloc];
}

#pragma mark CALayer

- (void)drawInContext:(CGContextRef)ctx {
	CGFloat viewDistance = sqrtf(viewVector.x * viewVector.x + viewVector.y * viewVector.y);
	
	// Correct for the cutoff that happens when the device is in the horizontal position (i.e. when isDeviceInHorizontalPosition is YES)
	double horizontalCutoffViewDistance = sin(HORIZONAL_THRESHOLD_ANGLE_HIGH);
	double correctedViewDistance = MAX(0.0, MIN((viewDistance - horizontalCutoffViewDistance) / (1.0 - horizontalCutoffViewDistance), 1.0));
	CGPoint correctedViewVector;
	correctedViewVector.x = viewVector.x * correctedViewDistance / viewDistance;
	correctedViewVector.y = viewVector.y * correctedViewDistance / viewDistance;

	// Don't need to draw anything if the corrected view distance is zero
	if (correctedViewDistance < 10e-6) {
		return;
	}

	CGRect bounds = [self bounds];
	
	// Transform to a flipped unit coordinate system
	CGContextScaleCTM(ctx, bounds.size.width / 2.0, bounds.size.height / 2.0);
	CGContextTranslateCTM(ctx, 1.0, 1.0);
	CGContextScaleCTM(ctx, 1.0, -1.0);

	CGFloat viewHeading = atan2f(viewVector.y, viewVector.x);
	CGFloat angleOfView = [[ARCamera sharedCamera] angleOfView];
	
	// Determine the area indicating the extent of view
	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, 0, 0);
	CGContextAddArc(ctx, 0, 0, correctedViewDistance, viewHeading + angleOfView / 2., viewHeading - angleOfView / 2., ARC_CLOCKWISE);
	CGContextClosePath(ctx);
	
	// Clip to that area and fill it with a gradient
	CGContextSaveGState(ctx);
	CGContextClip(ctx);
	CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), correctedViewVector, 0);
	CGContextRestoreGState(ctx);
}

#pragma mark ARRadarExtentOfViewLayer

- (void)setViewVector:(CGPoint)aViewVector {
	viewVector = aViewVector;
	
	[self setNeedsDisplay];
}

@end


@implementation ARRadarBlipsLayer

@synthesize features, radius, spatialState;

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		[self setNeedsDisplay];
		[self setNeedsDisplayOnBoundsChange:YES];
		
		radius = DEFAULT_RADIUS;
	}
	return self;
}

- (void)dealloc {
	[features release];
	[spatialState release];
	
	[super dealloc];
}

#pragma mark CALayer

- (void)drawInContext:(CGContextRef)ctx {
	CGRect bounds = [self bounds];
	
	// Transform origin to the center
	CGContextTranslateCTM(ctx, bounds.size.width / 2.0, bounds.size.height / 2.0);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	
	// Determine the horizontal and vertical scale
	CGFloat horizontalENUToScreenScale = (bounds.size.width / 2. - BLIB_SIZE / 2.) / radius;
	CGFloat verticalENUToScreenScale = (bounds.size.height / 2. - BLIB_SIZE / 2.) / radius;

	CGContextSetRGBFillColor(ctx, 1.0, 0.35, 0.76, 1.0);
	for (ARFeature *feature in features) {
		// Immediately skip features that should not be displayed on the radar
		if (![feature showInRadar]) {
		//	continue;
		}

		ARPoint3D featureLocationInECEFSpace = [[feature location] locationInECEFSpace];

		// Also skip features that are on the other side of the planet
		if (ARPoint3DDotProduct(featureLocationInECEFSpace, [spatialState locationInECEFSpace]) < 0) {
			continue;
		}
		
		ARPoint3D featureLocationInEFSpace = ARPoint3DSubtract(featureLocationInECEFSpace, [spatialState EFToECEFSpaceOffset]);
		ARPoint3D featureLocationInENUSpace = ARTransform3DHomogeneousVectorMatrixMultiply(featureLocationInEFSpace, [spatialState EFToENUSpaceTransform]);

		// TODO: We are applying the offset here as well as in ARFeatureView; refactor so that the offset only has to be applied once.
		featureLocationInENUSpace = ARPoint3DAdd(featureLocationInENUSpace, [feature offset]);
		
		// Now check whether the feature is still in range
		if (featureLocationInENUSpace.x * featureLocationInENUSpace.x + featureLocationInENUSpace.y * featureLocationInENUSpace.y <= radius * radius) {
			CGPoint featurePoint = CGPointMake(featureLocationInENUSpace.x * horizontalENUToScreenScale, featureLocationInENUSpace.y * verticalENUToScreenScale);
			CGContextFillEllipseInRect(ctx, CGRectMake(featurePoint.x - BLIB_SIZE / 2., featurePoint.y - BLIB_SIZE / 2., BLIB_SIZE, BLIB_SIZE));
		}
	}
}

#pragma mark ARRadarBlipsLayer

- (void)setFeatures:(NSArray *)someFeatures {
	[features release];
	features = [someFeatures copy];
	
	[self setNeedsDisplay];
}

- (void)setRadius:(CGFloat)aRadius {
	if (aRadius <= 0) {
		radius = DEFAULT_RADIUS;
	}
	else {
		radius = aRadius;
	}
	
	[self setNeedsDisplay];
}

- (void)setSpatialState:(ARSpatialState *)aSpatialState {
	// Only redraw when the location has changed
	if (!ARPoint3DEquals([spatialState locationInECEFSpace], [aSpatialState locationInECEFSpace])) {
		[self setNeedsDisplay];
	}
	
	[aSpatialState retain];
	[spatialState release];
	spatialState = aSpatialState;
}

@end
