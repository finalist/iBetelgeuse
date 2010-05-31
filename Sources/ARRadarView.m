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
#define RADAR_HORIZONAL_THRESHOLD_ANGLE (15. / 180. * M_PI) // If the angle between the device XY plane and the horizon plane, the device is considered to be flat and the heading inaccurate. The view direction will therefore be hidden and the heading determination algorithm will be changed to perform better with almost-parallel up- and view vectors.


@implementation ARRadarView

@synthesize features;

- (void)updateWithSpatialState:(ARSpatialStateManager *)spatialState usingRelativeAltitude:(BOOL)useRelativeAltitude {
	altitudeOffset = useRelativeAltitude ? [spatialState altitude] : 0.;
	ECEFToENUSpaceTransform = [spatialState ECEFToENUSpaceTransform];
	DeviceToENUSpaceTransform = ARTransform3DTranspose([spatialState ENUToDeviceSpaceTransform]);
	upDirectionInDeviceSpace = [spatialState upDirectionInDeviceSpace];
	isSpatialStateDefined = true;
	
	[self setBackgroundColor:[UIColor clearColor]];
	[self setClearsContextBeforeDrawing:NO];
	[self setNeedsDisplay];
}

- (CATransform3D)ENUToRadarSpaceTransformWithUpDirectionInRadarSpace:(ARPoint3D)upDirectionInRadarSpace lookVectorInENUSpace:(ARPoint3D)lookVectorInENUSpace  {
	// Map space defines a top-down orthogonal projection oriented so that the y axis matches the looking direction
	// Radar space defines the on-screen radar, so that the top of the displayed radar matches the y axis in map space.
	
	CATransform3D ENUToRadarTransform;
	
	// If the user looks straight down, the normal method becomes unusable due to the look vector being (almost) parallel to the up vector.
	if (lookVectorInENUSpace.z < -cosf(RADAR_HORIZONAL_THRESHOLD_ANGLE))
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
	CGContextSetFillColorWithColor(ctx, [[UIColor darkGrayColor] CGColor]);
	CGContextFillEllipseInRect(ctx, [self bounds]);
	
	// Prepare the screen transformation for drawing radar blibs
	CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(RADAR_SCREEN_RANGE, RADAR_SCREEN_RANGE));
	CGContextScaleCTM(ctx, 1, -1);
	
	if (isSpatialStateDefined)
	{
		ARPoint3D upDirectionInRadarSpace = (ARPoint3DCreate(upDirectionInDeviceSpace.x, upDirectionInDeviceSpace.y, 0));
		
		ARPoint3D lookVectorInDeviceSpace = ARPoint3DCreate(0, 0, -1);
		ARPoint3D lookVectorInENUSpace = ARTransform3DHomogeneousVectorMatrixMultiply(lookVectorInDeviceSpace, DeviceToENUSpaceTransform);
		
		// If not looking directly up or down, show the line of sight on the radar
		if (fabs(lookVectorInENUSpace.z) < cosf(RADAR_HORIZONAL_THRESHOLD_ANGLE)) {
			CGContextSetLineWidth(ctx, 1);
			CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
			CGContextStrokeLineSegments(ctx, (CGPoint[]){ CGPointMake(0, 0), CGPointMake(upDirectionInRadarSpace.x * RADAR_SCREEN_RANGE, upDirectionInRadarSpace.y * RADAR_SCREEN_RANGE) }, 2);
		}
		
		// Looking straight up makes radar orientation meaningless and makes the 'compass needle' spin. Therefore avoid drawing the radar at all if the user looks up over 80 degrees.
		if (lookVectorInENUSpace.z < cosf(RADAR_HORIZONAL_THRESHOLD_ANGLE)) {
			ARTransform3D ENUToRadarTransform = [self ENUToRadarSpaceTransformWithUpDirectionInRadarSpace:upDirectionInRadarSpace lookVectorInENUSpace:lookVectorInENUSpace];
			
			for (ARFeature *feature in features) {
				// TODO: We are now applying the offset here as well as in ARFeatureView, refactor so that the offset only has to be applied once.
				ARPoint3D offsetInENUSpace = [feature offset];
				offsetInENUSpace.z += altitudeOffset;
				
				ARPoint3D featurePositionInECEFSpace = [[feature location] ECEFCoordinate];
				ARPoint3D featurePositionInENUSpace = ARTransform3DHomogeneousVectorMatrixMultiply(featurePositionInECEFSpace, ECEFToENUSpaceTransform);
				featurePositionInENUSpace = ARPoint3DAdd(featurePositionInENUSpace, [feature offset]);
				ARPoint3D featurePositionInRadarSpace = ARTransform3DHomogeneousVectorMatrixMultiply(featurePositionInENUSpace, ENUToRadarTransform);
				
				[self drawBlibWithContext:ctx positionInRadarSpace:featurePositionInRadarSpace sizeInPixels:RADAR_BLIB_SIZE color:[[UIColor redColor] CGColor]];
			}
		}
	}
}

@end
