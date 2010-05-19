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
#import <QuartzCore/QuartzCore.h>


#define CAMERA_CONTROLS_HEIGHT (53.)
#define CAMERA_VIEW_SCALE (480. / (480. - CAMERA_CONTROLS_HEIGHT))


@interface ARMainController ()

@property(nonatomic, retain) ARDimension *dimension;
@property(nonatomic, readonly) UIImagePickerController *cameraViewController;
@property(nonatomic, readonly) UIView *featureContainerView;
@property(nonatomic, readonly) UIView *overlayContainerView;
//@property(nonatomic, readonly) ARRadarView *radarView;

- (void)createOverlayViews;

@end


@implementation ARMainController

@synthesize dimension;
@synthesize featureContainerView;
@synthesize overlayContainerView;
//@synthesize radarView;

#pragma mark NSObject

- (void)dealloc {
	[dimension release];
	[cameraViewController release];
	
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
	[view addSubview:featureContainerView];
	[featureContainerView release];
	
	overlayContainerView = [[UIView alloc] init];
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
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[self cameraViewController] viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[self cameraViewController] viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[[self cameraViewController] viewDidDisappear:animated];
}

#pragma mark ARDimensionRequestDelegate

- (void)dimensionRequest:(ARDimensionRequest *)request didFinishWithDimension:(ARDimension *)aDimension {
	[self setDimension:aDimension];
	[self createOverlayViews];
}

- (void)dimensionRequest:(ARDimensionRequest *)request didFailWithError:(NSError *)error {
	// TODO
	// Note: why can't we hold on to the dimension we had?
//	[dimension release];
//	dimension = nil;
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

- (void)createOverlayViews {
	for (AROverlay *overlay in [dimension overlays]) {
		AROverlayView* view = [AROverlayView viewForOverlay:overlay];
		[[view layer] setPosition:[overlay origin]];
		[overlayContainerView addSubview:view];
	}
}

@end
