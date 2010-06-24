//
//  ARCamera.m
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

#import "ARCamera.h"
#import <UIKit/UIKit.h>
#import "UIDevice+ARDevice.h"


// Taken from an iPhone 3GS
#define DEFAULT_PHYSICAL_FOCAL_LENGTH (3.85e-3)
#define DEFAULT_PHYSICAL_IMAGE_PLANE_WIDTH (2.69e-3)
#define DEFAULT_PHYSICAL_IMAGE_PLANE_HEIGHT (3.58e-3)

// Based on comfortably looking at an iPad at about arm's length
#define VIRTUAL_FOCAL_LENGTH 0.5
#define VIRTUAL_IMAGE_PLANE_WIDTH 0.15
#define VIRTUAL_IMAGE_PLANE_HEIGHT 0.2

#define CAMERA_MODELS_FILE_NAME @"Camera"
#define CAMERA_MODELS_FILE_EXTENSION @"plist"
#define FOCAL_LENGTH_KEY @"focalLength"
#define IMAGE_PLANE_WIDTH_KEY @"imagePlaneWidth"
#define IMAGE_PLANE_HEIGHT_KEY @"imagePlaneHeight"


static ARCamera *sharedInstance = nil;


@implementation ARCamera

@synthesize physical, focalLength, imagePlaneSize;
@synthesize distanceToViewPlane, angleOfView, perspectiveTransform;

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		physical = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
		
		if (physical) {
			// Set defaults
			focalLength = DEFAULT_PHYSICAL_FOCAL_LENGTH;
			imagePlaneSize.width = DEFAULT_PHYSICAL_IMAGE_PLANE_WIDTH;
			imagePlaneSize.height = DEFAULT_PHYSICAL_IMAGE_PLANE_HEIGHT;
			
			// Try to override the defaults 
			NSString *modelIdentifier = [[UIDevice currentDevice] ar_modelIdentifier];
			NSDictionary *models = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:CAMERA_MODELS_FILE_NAME ofType:CAMERA_MODELS_FILE_EXTENSION]];
			NSDictionary *model = [models objectForKey:modelIdentifier];
			if (model) {
				focalLength = [[model objectForKey:FOCAL_LENGTH_KEY] floatValue];
				imagePlaneSize.width = [[model objectForKey:IMAGE_PLANE_WIDTH_KEY] floatValue];
				imagePlaneSize.height = [[model objectForKey:IMAGE_PLANE_HEIGHT_KEY] floatValue];
			}
			[models release];
		}
		else {
			focalLength = VIRTUAL_FOCAL_LENGTH;
			imagePlaneSize.width = VIRTUAL_IMAGE_PLANE_WIDTH;
			imagePlaneSize.height = VIRTUAL_IMAGE_PLANE_HEIGHT;
		}
		
		distanceToViewPlane = 2. * focalLength / MAX(imagePlaneSize.width, imagePlaneSize.height);
		
		angleOfView = 2. * tanf(1. / distanceToViewPlane);
		
		perspectiveTransform = CATransform3DIdentity;
		// Inverted because the depth increases as the z-axis decreases (going from 0 towards negative values)
		perspectiveTransform.m34 = -1. / distanceToViewPlane; 
		perspectiveTransform.m44 = 0.;
	}
	return self;
}

#pragma mark ARCamera

+ (ARCamera *)sharedCamera {
	if (sharedInstance == nil) {
		sharedInstance = [[ARCamera alloc] init];
	}
	return sharedInstance;
}

@end
