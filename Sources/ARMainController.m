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


#define CAMERA_CONTROLS_HEIGHT (53.)
#define CAMERA_VIEW_SCALE (480. / (480. - CAMERA_CONTROLS_HEIGHT))


@interface ARMainController ()

//@property(nonatomic, readonly) ARDimension *dimension;
@property(nonatomic, readonly) UIImagePickerController *cameraViewController;
@property(nonatomic, readonly) UIView *featureContainerView;
@property(nonatomic, readonly) UIView *overlayContainerView;
//@property(nonatomic, readonly) ARRadarView *radarView;

@end


@implementation ARMainController

//@synthesize dimension;
@synthesize cameraViewController;
@synthesize featureContainerView;
@synthesize overlayContainerView;
//@synthesize radarView;

#pragma mark NSObject

- (void)dealloc {
	[cameraViewController release];
	[super dealloc];
}

#pragma mark UIViewController

- (void)loadView {
	[super loadView];
	UIView *view = [self view];
	
	cameraViewController = [[UIImagePickerController alloc] init];
	[cameraViewController setSourceType:UIImagePickerControllerSourceTypeCamera];
	[cameraViewController setShowsCameraControls:NO];
	[cameraViewController setCameraViewTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(CAMERA_VIEW_SCALE, CAMERA_VIEW_SCALE), 0, CAMERA_CONTROLS_HEIGHT / 2)];
	
	UIView *cameraView = [cameraViewController view];
	[view addSubview:cameraView];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[cameraViewController release];
	cameraViewController = nil;
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

@end
