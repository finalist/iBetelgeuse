//
//  ARMainController.m
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

#import "ARMainController.h"
#import "ARDimension.h"
#import "AROverlay.h"
#import "AROverlayView.h"
#import "ARFeature.h"
#import "ARFeatureView.h"
#import "ARTransform3D.h"
#import "ARSpatialStateManager.h"
#import "ARWGS84.h"
#import "ARLocation.h"
#import <QuartzCore/QuartzCore.h>


#define SCREEN_SIZE_X 320
#define SCREEN_SIZE_Y 480
#define CAMERA_CONTROLS_HEIGHT (53.)
#define CAMERA_VIEW_SCALE (SCREEN_SIZE_Y / (SCREEN_SIZE_Y - CAMERA_CONTROLS_HEIGHT))
#define CAMERA_FOCAL_LENGTH (3.85e-3)
#define CAMERA_SENSOR_SIZE_X (2.69e-3)
#define CAMERA_SENSOR_SIZE_Y (3.58e-3)


@interface ARMainController ()

@property(nonatomic, retain) NSURL *dimensionURL;
@property(nonatomic, retain) ARDimension *dimension;
@property(nonatomic, readonly) UIImagePickerController *cameraViewController;
@property(nonatomic, readonly) UIView *featureContainerView;
@property(nonatomic, readonly) UIView *overlayContainerView;
//@property(nonatomic, readonly) ARRadarView *radarView;

@property(nonatomic, retain) ARDimensionRequest *dimensionRequest;
@property(nonatomic, readonly) ARSpatialStateManager *spatialStateManager;

- (UIImagePickerController *)cameraViewController;
- (CATransform3D)perspectiveTransform;
- (void)createOverlayViews;
- (void)createFeatureViews;
- (void)updateFeatureViews;

@end


@implementation ARMainController

@synthesize dimensionURL;
@synthesize dimension;
@synthesize featureContainerView;
@synthesize overlayContainerView;
//@synthesize radarView;

@synthesize dimensionRequest;

#pragma mark NSObject

- (id)init {
	return [self initWithURL:nil];
}

- (id)initWithURL:(NSURL *)aURL {
	if (self = [super init]) {
		dimensionURL = [aURL retain];
		
		if (dimensionURL) {
			// FIXME: Send request only after first location fix
			ARLocation *fakeLocation = [[ARLocation alloc] initWithLatitude:0.0 longitude:0.0 altitude:0.0];
			ARDimensionRequest *request = [[ARDimensionRequest alloc] initWithURL:aURL location:fakeLocation type:ARDimensionRequestTypeInit];
			[request setDelegate:self];
			[self setDimensionRequest:request];
			[request release];
			[fakeLocation release];
			
			[request start];
		}
	}
	return self;
}

- (void)dealloc {
	[dimensionURL release];
	[dimension release];
	[cameraViewController release];
	
	[dimensionRequest release];
	[spatialStateManager release];
	
	[super dealloc];
}

#pragma mark UIViewController

- (void)loadView {
	[super loadView];
	UIView *view = [self view];
	
#if !TARGET_IPHONE_SIMULATOR
	[view addSubview:[[self cameraViewController] view]];
#endif

	featureContainerView = [[UIView alloc] init];
	[featureContainerView setFrame:[view bounds]];
	[featureContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[[featureContainerView layer] setAnchorPoint:CGPointMake(0, 0)];
	[view addSubview:featureContainerView];
	[featureContainerView release];
	
	overlayContainerView = [[UIView alloc] init];
	[overlayContainerView setFrame:[view bounds]];
	[overlayContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[view addSubview:overlayContainerView];
	[overlayContainerView release];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[cameraViewController release];
	cameraViewController = nil;
	featureContainerView = nil;
	overlayContainerView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[self cameraViewController] viewWillAppear:animated];
	
	[[self spatialStateManager] startUpdating];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[self cameraViewController] viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[self cameraViewController] viewWillDisappear:animated];
	
	[[self spatialStateManager] stopUpdating];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[[self cameraViewController] viewDidDisappear:animated];
}

#pragma mark ARDimensionRequestDelegate

- (void)dimensionRequest:(ARDimensionRequest *)request didFinishWithDimension:(ARDimension *)aDimension {
	[self setDimension:aDimension];
	[self setDimensionRequest:nil];
	
	[self createOverlayViews];
	[self createFeatureViews];
}

- (void)dimensionRequest:(ARDimensionRequest *)request didFailWithError:(NSError *)error {
	[self setDimensionRequest:nil];
	
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:NSLocalizedString(@"Could not update dimension", @"main controller alert title")];
	[alert setMessage:[error localizedDescription]];
	[alert addButtonWithTitle:NSLocalizedString(@"Close", @"main controller alert button")];
	[alert show];
	[alert release];
}

#pragma mark ARSpatialStateManagerDelegate

- (void)spatialStateManagerDidUpdate:(ARSpatialStateManager *)manager {
	[self updateFeatureViews];
}

#pragma mark ARMainController

- (UIImagePickerController *)cameraViewController {
	// Lazily create camera view controller, if necessary
	if (cameraViewController == nil) {
#if !TARGET_IPHONE_SIMULATOR
		cameraViewController = [[UIImagePickerController alloc] init];
		[cameraViewController setSourceType:UIImagePickerControllerSourceTypeCamera];
		[cameraViewController setShowsCameraControls:NO];
		[cameraViewController setCameraViewTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(CAMERA_VIEW_SCALE, CAMERA_VIEW_SCALE), 0, CAMERA_CONTROLS_HEIGHT / 2)];
#endif
	}
	return cameraViewController;
}

- (ARSpatialStateManager *)spatialStateManager {
	if (spatialStateManager == nil) {
		spatialStateManager = [[ARSpatialStateManager alloc] init];
		[spatialStateManager setDelegate:self];
	}
	return spatialStateManager;
}

- (CATransform3D)screenTransform {
	// Invert the y-axis because the view y-axis extends towards the bottom, not the top, of the device
	return CATransform3DMakeScale(SCREEN_SIZE_Y / 2., -SCREEN_SIZE_Y / 2., 1.);
}

- (CATransform3D)perspectiveTransform {
	CATransform3D perspectiveTransform = CATransform3DIdentity;
	// Inverted because the depth increases as the z-axis decreases (going from 0 towards negative values)
	perspectiveTransform.m34 = -.5 * CAMERA_SENSOR_SIZE_Y / CAMERA_FOCAL_LENGTH; 
	perspectiveTransform.m44 = 0.;
	return perspectiveTransform;
}

- (void)createOverlayViews {
	// Remove all existing overlay views
	UIView *view;
	while (view = [[overlayContainerView subviews] lastObject]) {
		[view removeFromSuperview];
	}
	
	for (AROverlay *overlay in [dimension overlays]) {
		AROverlayView* view = [AROverlayView viewForOverlay:overlay];
		[[view layer] setPosition:[overlay origin]];
		[overlayContainerView addSubview:view];
	}
}

- (void)createFeatureViews {
	// Remove all existing feature views
	UIView *view;
	while (view = [[featureContainerView subviews] lastObject]) {
		[view removeFromSuperview];
	}
	
	for (ARFeature *feature in [dimension features]) {
		[featureContainerView addSubview:[ARFeatureView viewForFeature:feature]];
	}
	
	[self updateFeatureViews];
}

- (void)updateFeatureViews {
	CATransform3D featureContainerTransform = CATransform3DIdentity;
	featureContainerTransform = CATransform3DConcat(featureContainerTransform, [spatialStateManager ECEFToENUSpaceTransform]);
	featureContainerTransform = CATransform3DConcat(featureContainerTransform, [spatialStateManager ENUToDeviceSpaceTransform]);
	featureContainerTransform = CATransform3DConcat(featureContainerTransform, [self perspectiveTransform]);
	featureContainerTransform = CATransform3DConcat(featureContainerTransform, [self screenTransform]);
	
	// Disable implicit animations
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	[[featureContainerView layer] setSublayerTransform:featureContainerTransform];

	for (ARFeatureView *featureView in [featureContainerView subviews]) {
		NSAssert([featureView isKindOfClass:[ARFeatureView class]], nil);		
		[featureView updateWithSpatialState:spatialStateManager];
	}

	[CATransaction commit];
}

@end
