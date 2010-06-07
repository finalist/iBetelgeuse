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
#import "ARTransform3D.h"

#define RADAR_RANGE 550
#define RADAR_SCREEN_RANGE 50
#define RADAR_BLIB_SIZE 4

// If the device is in horizontal position (the screen normal vector is pointed upwards or downwards within the threshold specified below), the heading is undefined or inaccurate. The view direction will therefore be hidden and the heading determination algorithm will be changed to perform better with almost-parallel up- and view vectors. The high and low threshold values are used to avoid jitter between the two behaviours due to noise if the angle is close to the threshold angle.
#define RADAR_HORIZONAL_THRESHOLD_ANGLE_LOW (15. / 180. * M_PI)
#define RADAR_HORIZONAL_THRESHOLD_ANGLE_HIGH (20. / 180. * M_PI)


@implementation ARRadarView

@synthesize features;

- (id)initWithFrame:(CGRect)aFrame {
	if (self = [super initWithFrame:aFrame]) {
		[self setClearsContextBeforeDrawing:YES];
		[self setOpaque:NO];
	}
	return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	point.x -= RADAR_SCREEN_RANGE;
	point.y -= RADAR_SCREEN_RANGE;
	return point.x * point.x + point.y * point.y <= RADAR_SCREEN_RANGE * RADAR_SCREEN_RANGE;
}

- (void)updateWithSpatialState:(ARSpatialState *)spatialState usingRelativeAltitude:(BOOL)useRelativeAltitude {
	ARPoint3D lookVectorInDeviceSpace = ARPoint3DCreate(0., 0., -1.);
	
	altitudeOffset = useRelativeAltitude ? [spatialState altitude] : 0.;
	EFToECEFSpaceOffset = [spatialState EFToECEFSpaceOffset];
	EFToENUSpaceTransform = [spatialState EFToENUSpaceTransform];
	DeviceToENUSpaceTransform = ARTransform3DTranspose([spatialState ENUToDeviceSpaceTransform]);
	lookVectorInENUSpace = ARTransform3DHomogeneousVectorMatrixMultiply(lookVectorInDeviceSpace, DeviceToENUSpaceTransform);
	upDirectionInDeviceSpace = [spatialState upDirectionInDeviceSpace];
	isSpatialStateDefined = YES;

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
	if ([self isDeviceInHorizontalPosition])
	{
		// The normal method is unusable; compute the heading using the look vector instead.
		ARPoint3D yLookVectorInDeviceSpace = ARPoint3DCreate(0, 1, 0);
		ARPoint3D yLookVectorInENUSpace = ARTransform3DHomogeneousVectorMatrixMultiply(yLookVectorInDeviceSpace, DeviceToENUSpaceTransform);
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

- (void)drawBlibWithContext:(CGContextRef)ctx positionInRadarSpace:(ARPoint3D)positionInRadarSpace sizeInPixels:(float)sizeInPixels color:(CGColorRef)color {
	CGPoint projectedPosition = CGPointMake(positionInRadarSpace.x * RADAR_SCREEN_RANGE / RADAR_RANGE, positionInRadarSpace.y * RADAR_SCREEN_RANGE / RADAR_RANGE);
	if (projectedPosition.x*projectedPosition.x + projectedPosition.y*projectedPosition.y <= RADAR_SCREEN_RANGE*RADAR_SCREEN_RANGE) {
		CGContextSetFillColorWithColor(ctx, color);
		CGContextFillEllipseInRect(ctx, CGRectMake(projectedPosition.x-sizeInPixels/2, projectedPosition.y-sizeInPixels/2, sizeInPixels, sizeInPixels));
	}
}

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// Draw the outer radar circle
	CGContextSetBlendMode(ctx, kCGBlendModeCopy);
	CGContextSetGrayFillColor(ctx, 0.333, 0.667);
	CGContextFillEllipseInRect(ctx, [self bounds]);
	
	// Prepare the screen transformation for drawing radar blibs
	CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(RADAR_SCREEN_RANGE, RADAR_SCREEN_RANGE));
	CGContextScaleCTM(ctx, 1, -1);
	
	if (isSpatialStateDefined)
	{
		ARPoint3D upDirectionInRadarSpace = ARPoint3DCreate(upDirectionInDeviceSpace.x, upDirectionInDeviceSpace.y, 0);
		
		if ([self isReliable]) {
			// If not looking directly up or down, show the line of sight on the radar
			if (![self isDeviceInHorizontalPosition]) {
				ARPoint3D lookDirectionInScreenSpace = ARPoint3DCreate(upDirectionInRadarSpace.x, upDirectionInRadarSpace.y, 0.);
				float lookDirectionInScreenSpaceLength = ARPoint3DLength(lookDirectionInScreenSpace);
				if (lookDirectionInScreenSpaceLength > 1.f) {
					lookDirectionInScreenSpace = ARPoint3DScale(lookDirectionInScreenSpace, 1.f / lookDirectionInScreenSpaceLength);
				}
				CGContextSetLineWidth(ctx, 1);
				CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
				CGContextStrokeLineSegments(ctx, (CGPoint[]){ CGPointMake(0, 0), CGPointMake(lookDirectionInScreenSpace.x * RADAR_SCREEN_RANGE, lookDirectionInScreenSpace.y * RADAR_SCREEN_RANGE) }, 2);
			}
			
			ARTransform3D ENUToRadarTransform = [self ENUToRadarSpaceTransformWithUpDirectionInRadarSpace:upDirectionInRadarSpace];
			for (ARFeature *feature in features) {
				// TODO: We are now applying the offset here as well as in ARFeatureView, refactor so that the offset only has to be applied once.
				ARPoint3D offsetInENUSpace = [feature offset];
				offsetInENUSpace.z += altitudeOffset;
				
				ARPoint3D featurePositionInEFSpace = ARPoint3DSubtract([[feature location] locationInECEFSpace], EFToECEFSpaceOffset);
				ARPoint3D featurePositionInENUSpace = ARTransform3DHomogeneousVectorMatrixMultiply(featurePositionInEFSpace, EFToENUSpaceTransform);
				featurePositionInENUSpace = ARPoint3DAdd(featurePositionInENUSpace, [feature offset]);
				ARPoint3D featurePositionInRadarSpace = ARTransform3DHomogeneousVectorMatrixMultiply(featurePositionInENUSpace, ENUToRadarTransform);
				
				[self drawBlibWithContext:ctx positionInRadarSpace:featurePositionInRadarSpace sizeInPixels:RADAR_BLIB_SIZE color:[[UIColor redColor] CGColor]];
			}
		}
	}
}

@end
