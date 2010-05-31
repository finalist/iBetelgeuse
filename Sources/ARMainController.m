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
#import "ARRadarView.h"
#import "ARAssetDataUser.h"
#import <QuartzCore/QuartzCore.h>


#define SCREEN_SIZE_X 320
#define SCREEN_SIZE_Y 480
#define CAMERA_CONTROLS_HEIGHT (53.)
#define CAMERA_VIEW_SCALE (SCREEN_SIZE_Y / (SCREEN_SIZE_Y - CAMERA_CONTROLS_HEIGHT))
#define CAMERA_FOCAL_LENGTH (3.85e-3)
#define CAMERA_SENSOR_SIZE_X (2.69e-3)
#define CAMERA_SENSOR_SIZE_Y (3.58e-3)
#define INVERTED_DISTANCE_TO_VIEW_PLANE (.5 * CAMERA_SENSOR_SIZE_Y / CAMERA_FOCAL_LENGTH)
#define DISTANCE_FACTOR (INVERTED_DISTANCE_TO_VIEW_PLANE / (SCREEN_SIZE_Y / 2.)) // Factor that is used to undo the view and projection transformations


@interface ARMainController ()

@property(nonatomic, retain) NSURL *pendingDimensionURL;
@property(nonatomic, retain) ARDimension *dimension;
@property(nonatomic, readonly) UIImagePickerController *cameraViewController;
@property(nonatomic, readonly) UIView *featureContainerView;
@property(nonatomic, readonly) UIView *overlayContainerView;
//@property(nonatomic, readonly) ARRadarView *radarView;

@property(nonatomic, retain) ARDimensionRequest *dimensionRequest;
@property(nonatomic, readonly) ARAssetManager *assetManager;
@property(nonatomic, readonly) ARAssetManager *assetManagerIfAvailable;
@property(nonatomic, readonly) ARSpatialStateManager *spatialStateManager;
@property(nonatomic, retain) NSTimer *refreshTimer;
@property(nonatomic, getter=isRefreshingOnDistance) BOOL refreshingOnDistance;
@property(nonatomic, retain) ARLocation *refreshLocation;

- (UIImagePickerController *)cameraViewController;
- (CATransform3D)perspectiveTransform;
- (void)createOverlayViews;
- (void)createFeatureViews;
- (void)updateFeatureViews;

- (void)startDimensionRequestWithURL:(NSURL *)aURL type:(ARDimensionRequestType)type;
- (void)startRefreshingOnTime;
- (void)stopRefreshingOnTime;
- (void)startRefreshingOnDistanceResetLocation:(BOOL)reset;
- (void)stopRefreshingOnDistance;

@end


@implementation ARMainController

@synthesize pendingDimensionURL;
@synthesize dimension;
@synthesize featureContainerView;
@synthesize overlayContainerView;
//@synthesize radarView;

@synthesize dimensionRequest;
@synthesize refreshTimer;
@synthesize refreshingOnDistance;
@synthesize refreshLocation;

#pragma mark NSObject

- (id)init {
	return [self initWithURL:nil];
}

- (id)initWithURL:(NSURL *)aURL {
	if (self = [super init]) {
		pendingDimensionURL = [aURL retain];
		
		if (aURL) {
			DebugLog(@"Got dimension URL, waiting for location fix");
		}
	}
	return self;
}

- (void)dealloc {
	[pendingDimensionURL release];
	[dimension release];
	[cameraViewController release];
	
	[dimensionRequest release];
	[assetManager release];
	[spatialStateManager release];
	[refreshTimer invalidate];
	[refreshTimer release];
	[refreshLocation release];
	
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
	
	radarView = [[ARRadarView alloc] init];
	[radarView setFrame:CGRectMake(10, 480-100-10, 100, 100)];
	[view addSubview:radarView];
	[radarView release];
	
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
	// Save the dimension
	[self setDimension:aDimension];
	
	// Forget the dimension request
	[self setDimensionRequest:nil];

	// Cancel loading any assets before we start reloading them in the create... methods below
	[[self assetManagerIfAvailable] cancelLoadingAllAssets];
	
	[self createOverlayViews];
	[self createFeatureViews];
	[radarView setFeatures:[dimension features]];
	
	[self startRefreshingOnTime];
	[self startRefreshingOnDistanceResetLocation:YES];
}

- (void)dimensionRequest:(ARDimensionRequest *)request didFailWithError:(NSError *)error {
	// Forget the dimension request
	[self setDimensionRequest:nil];

	[self startRefreshingOnTime];
	[self startRefreshingOnDistanceResetLocation:NO];
	
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:NSLocalizedString(@"Could not update dimension", @"main controller alert title")];
	[alert setMessage:[error localizedDescription]];
	[alert addButtonWithTitle:NSLocalizedString(@"Close", @"main controller alert button")];
	[alert show];
	[alert release];
}

#pragma mark ARAssetManagerDelegate

- (void)assetManager:(ARAssetManager *)manager didLoadData:(NSData *)data forAsset:(ARAsset *)asset {
	// Find overlays that need this data
	// TODO: Refactor
	for (UIView *view in [overlayContainerView subviews]) {
		if ([view conformsToProtocol:@protocol(ARAssetDataUser)]) {
			id <ARAssetDataUser> user = (id <ARAssetDataUser>)view;
			if ([[user assetIdentifiersForNeededData] containsObject:[asset identifier]]) {
				[user useData:data forAssetIdentifier:[asset identifier]];
			}
		}
	}
	
	// Find features that need this data
	// TODO: Refactor
	for (UIView *view in [featureContainerView subviews]) {
		if ([view conformsToProtocol:@protocol(ARAssetDataUser)]) {
			id <ARAssetDataUser> user = (id <ARAssetDataUser>)view;
			if ([[user assetIdentifiersForNeededData] containsObject:[asset identifier]]) {
				[user useData:data forAssetIdentifier:[asset identifier]];
			}
		}
	}
}

- (void)assetManager:(ARAssetManager *)manager didFailWithError:(NSError *)error forAsset:(ARAsset *)asset {
	// TODO: What to do with the overlay/feature views?
}

#pragma mark ARSpatialStateManagerDelegate

- (void)spatialStateManagerDidUpdate:(ARSpatialStateManager *)manager {
	[self updateFeatureViews];
}

- (void)spatialStateManagerLocationDidUpdate:(ARSpatialStateManager *)manager {
	// If we have a location fix, send a request for any pending URL
	if ([self pendingDimensionURL] && [manager location]) {
		[self startDimensionRequestWithURL:[self pendingDimensionURL] type:ARDimensionRequestTypeInit];
		[self setPendingDimensionURL:nil];
	}
	
	// Deal with the refresh location
	if ([self isRefreshingOnDistance] && [manager location]) {
		// If we don't have a refresh location yet, set it now
		if (![self refreshLocation]) {
			[self setRefreshLocation:[manager location]];
		}
		else if ([[manager location] straightLineDistanceToLocation:[self refreshLocation]] >= [dimension refreshDistance]) {
			[self startDimensionRequestWithURL:[[self dimension] refreshURL] type:ARDimensionRequestTypeDistanceRefresh];
			[self stopRefreshingOnDistance];
		}
	}
}

#pragma mark NSTimerInvocation

- (void)refreshTimerDidFire:(NSTimer *)aTimer {
	[self startDimensionRequestWithURL:[[self dimension] refreshURL] type:ARDimensionRequestTypeTimeRefresh];
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

- (ARAssetManager *)assetManager {
	if (assetManager == nil) {
		assetManager = [[ARAssetManager alloc] init];
		[assetManager setDelegate:self];
	}
	return assetManager;
}

- (ARAssetManager *)assetManagerIfAvailable {
	// This is an accessor that doesn't attempt to lazily create an asset manager
	return assetManager;
}

- (ARSpatialStateManager *)spatialStateManager {
	if (spatialStateManager == nil) {
		spatialStateManager = [[ARSpatialStateManager alloc] init];
		[spatialStateManager setDelegate:self];
	}
	return spatialStateManager;
}

- (void)setRefreshTimer:(NSTimer *)aTimer {
	if (refreshTimer != aTimer) {
		// Unschedule the existing timer from the runloop
		[refreshTimer invalidate];
		
		[refreshTimer release];
		refreshTimer = [aTimer retain];
	}
}

- (CATransform3D)screenTransform {
	// Invert the y-axis because the view y-axis extends towards the bottom, not the top, of the device
	return CATransform3DMakeScale(SCREEN_SIZE_Y / 2., -SCREEN_SIZE_Y / 2., 1.);
}

- (CATransform3D)perspectiveTransform {
	CATransform3D perspectiveTransform = CATransform3DIdentity;
	// Inverted because the depth increases as the z-axis decreases (going from 0 towards negative values)
	perspectiveTransform.m34 = -INVERTED_DISTANCE_TO_VIEW_PLANE; 
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
		
		// Start loading any needed asset data
		// TODO: Refactor this (see createFeatureViews)
		if ([view conformsToProtocol:@protocol(ARAssetDataUser)]) {
			id <ARAssetDataUser> user = (id <ARAssetDataUser>)view;
			for (NSString *identifier in [user assetIdentifiersForNeededData]) {
				ARAsset *asset = [[dimension assets] objectForKey:identifier];
				if (asset == nil) {
					DebugLog(@"Overlay view wants asset with non-existent identifier: %@", identifier);
				}
				else {
					[[self assetManager] startLoadingAsset:asset];
				}
			}
		}
	}
}

- (void)createFeatureViews {
	// Remove all existing feature views
	UIView *view;
	while (view = [[featureContainerView subviews] lastObject]) {
		[view removeFromSuperview];
	}
	
	for (ARFeature *feature in [dimension features]) {
		ARFeatureView *view = [ARFeatureView viewForFeature:feature];
		[featureContainerView addSubview:view];
		
		// Start loading any needed asset data
		// TODO: Refactor this (see createOverlayViews)
		if ([view conformsToProtocol:@protocol(ARAssetDataUser)]) {
			id <ARAssetDataUser> user = (id <ARAssetDataUser>)view;
			for (NSString *identifier in [user assetIdentifiersForNeededData]) {
				ARAsset *asset = [[dimension assets] objectForKey:identifier];
				if (asset == nil) {
					DebugLog(@"Feature view wants asset with non-existent identifier: %@", identifier);
				}
				else {
					[[self assetManager] startLoadingAsset:asset];
				}
			}
		}
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
		[featureView updateWithSpatialState:spatialStateManager usingRelativeAltitude:[dimension relativeAltitude] withDistanceFactor:DISTANCE_FACTOR];
	}

	[CATransaction commit];
	
	[radarView updateWithSpatialState:spatialStateManager usingRelativeAltitude:[dimension relativeAltitude]];
}

- (void)startDimensionRequestWithURL:(NSURL *)aURL type:(ARDimensionRequestType)type {
	NSAssert(aURL, @"Expected non-nil URL.");
	
	// Cancel loading any assets
	[[self assetManagerIfAvailable] cancelLoadingAllAssets];
	
	// Make sure to kill any timer, since we don't want it firing when we're already refreshing
	[self stopRefreshingOnTime];
	[self stopRefreshingOnDistance];

	ARDimensionRequest *request = [[ARDimensionRequest alloc] initWithURL:aURL location:[[self spatialStateManager] location] type:type];
	[request setDelegate:self];
	[self setDimensionRequest:request];
	[request release];

	[request start];
}

- (void)startRefreshingOnTime {
	if (![[self dimension] refreshURL] || [[self dimension] refreshTime] == ARDimensionRefreshTimeInfinite) {
		[self setRefreshTimer:nil];
		
		DebugLog(@"Dimension refresh timer not scheduled");
	}
	else {
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[[self dimension] refreshTime] target:self selector:@selector(refreshTimerDidFire:) userInfo:nil repeats:NO];
		[self setRefreshTimer:timer];
		
		DebugLog(@"Scheduling dimension refresh timer with timeout %fs", [[self dimension] refreshTime]);
	}
}

- (void)stopRefreshingOnTime {
	[self setRefreshTimer:nil];
}

- (void)startRefreshingOnDistanceResetLocation:(BOOL)reset {
	if (![[self dimension] refreshURL] || [[self dimension] refreshDistance] == ARDimensionRefreshDistanceInfinite) {
		[self setRefreshingOnDistance:NO];
	}
	else {
		[self setRefreshingOnDistance:YES];
		
		if (reset) {
			[self setRefreshLocation:[[self spatialStateManager] location]];
		}
	}
}

- (void)stopRefreshingOnDistance {
	[self setRefreshingOnDistance:NO];
}

@end
