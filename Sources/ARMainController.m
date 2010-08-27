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
#import "AROverlayContainerView.h"
#import "AROverlayView.h"
#import "ARHTMLOverlay.h"
#import "ARFeature.h"
#import "ARFeatureContainerView.h"
#import "ARFeatureView.h"
#import "ARAction.h"
#import "ARSpatialState.h"
#import "ARWGS84.h"
#import "ARLocation.h"
#import "ARLocationAnnotation.h"
#import "ARRadarView.h"
#import "ARScannerOverlayView.h"
#import "ARScannerFlash.h"
#import "ARButton.h"
#import "ARAssetDataUser.h"
#import "ARAboutController.h"
#import <QuartzCore/QuartzCore.h>
#import <zbar/ZBarImageScanner.h>
#import <MapKit/MapKit.h>


#define DIMENSION_URL_DEFAULTS_KEY @"dimensionURL"

#define MARGIN 10
#define BUTTON_HEIGHT 44
#define MENU_BUTTON_WIDTH 54
#define CANCEL_BUTTON_WIDTH 74

#define MENU_BUTTON_IMAGE @"ARMenuButton.png"

#define SCREEN_HEIGHT 480
#define CAMERA_CONTROLS_HEIGHT (53.)
#define CAMERA_VIEW_SCALE (SCREEN_HEIGHT / (SCREEN_HEIGHT - CAMERA_CONTROLS_HEIGHT))

// Fraction of the refresh rate of the screen at which to update
// Note: a frame interval of 2 results in 30 FPS and seems smooth enough
#define FRAME_INTERVAL 2

// Time interval between two QR scans.
#define SCAN_TIMER_INTERVAL 1

#define STATE_HIDDEN 0
#define STATE_DIMENSION 1
#define STATE_QR 2

#define MINIMUM_REFRESH_TIME_AFTER_ERROR 10. // seconds


// Expose undocumented API
#if defined(__clang__)
__attribute__((cf_returns_retained))
#endif
CGImageRef UIGetScreenImage(void);


@interface ARMainController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property(nonatomic, retain) NSURL *pendingDimensionURL;
@property(nonatomic, retain) ARDimension *dimension;
@property(nonatomic, readonly) UIImagePickerController *cameraViewController;
@property(nonatomic, readonly) ARFeatureContainerView *featureContainerView;
@property(nonatomic, readonly) AROverlayContainerView *overlayContainerView;
@property(nonatomic, readonly) ARRadarView *radarView;
@property(nonatomic, readonly) MKMapView *mapView;
@property(nonatomic, readonly) ARScannerOverlayView *scannerOverlayView;

@property(nonatomic, retain) CADisplayLink *displayLink;

@property(nonatomic, retain) ARDimensionRequest *dimensionRequest;
@property(nonatomic, readonly) ARAssetManager *assetManager;
@property(nonatomic, readonly) ARAssetManager *assetManagerIfAvailable;
@property(nonatomic, readonly) ARSpatialStateManager *spatialStateManager;
@property(nonatomic, retain) NSTimer *refreshTimer;
@property(nonatomic, retain) NSDate *refreshTime;
@property(nonatomic, getter=isRefreshingOnDistance) BOOL refreshingOnDistance;
@property(nonatomic, retain) ARLocation *refreshLocation;

/**
 * Callback for the display link.
 *
 * @param sender The sender of the message.
 */
- (void)updateWithDisplayLink:(CADisplayLink *)sender;

/**
 * Handle the refresh timer expiring; this should initite a dimension refresh.
 * @param aTimer the timer that expired.
 */
- (void)refreshTimerDidFire:(NSTimer *)aTimer;

/**
 * Handle the scan timer expiring; this should try to scan the current camera
 * image for QR codes and try to load it if found.
 */
- (void)scanTimerDidFire;

/**
 * Set the display link, stopping the current display link if it is already set.
 * @param aLink the new display link.
 */
- (void)setDisplayLink:(CADisplayLink *)aLink;

/**
 * Set the refresh timer, stopping the current timer if it is already set.
 * @param aTimer the new timer.
 */
- (void)setRefreshTimer:(NSTimer *)aTimer;

/**
 * Set the scan timer, stopping the current timer if it is already set.
 * @param aTimer the new timer.
 */
- (void)setScanTimer:(NSTimer *)aTimer;

/**
 * Update the elements on the screen so that they are in the proper positions
 * for the new orientation.
 *
 * @param interfaceOrientation The new orientation of the device.
 * @param animation Whether a change in the interface orientation will be animated. If this is YES, the methods is expected to be called again (with animation = NO) after the animation has finished.
 */
- (void)updateWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation prepareForAnimation:(BOOL)animation;

/**
 * Make the status bar visible if it is not already visible.
 */
- (void)ensureStatusBarVisible;

/**
 * Make the status bar visible.
 */
- (void)makeStatusBarVisible;

/**
 * Ensure that the overlay views for the overlays in the current dimension
 * exist, and remove overlays that are no longer in the dimension.
 */
- (void)createOverlayViews;

/**
 * Ensure that the feature views for the overlays in the current dimension
 * exist, and remove features that are no longer in the dimension.
 */
- (void)createFeatureViews;

/**
 * Update the features and radar, after the spatial state has changed.
 */
- (void)updateFeatureViews;

/**
 * Indicate that the views need to be updated.
 */
- (void)setNeedsUpdate;

/**
 * Update the warning indicator views, and if the view was previously invalidated update the feature views.
 */
- (void)updateIfNeeded;

/**
 * Start a dimension request, disabling updating and asset loading while the new
 * dimension is updated.
 * @param aURL the URL that should be loaded.
 * @param type the type of request.
 * @param source the identifier of the object that triggered this event.
 */
- (void)startDimensionRequestWithURL:(NSURL *)aURL type:(ARDimensionRequestType)type source:(NSString *)source;

/**
 * Schedule a dimension refresh when the defined time interval expires. Does
 * nothing if automatic updates should not be enabled, ie. when the dimension is
 * outdated, the refresh time is set to infinite or the refresh URL is not set.
 */
- (void)startRefreshingOnTime;


/**
 * Cancel the scheduled dimension refresh.
 */
- (void)stopRefreshingOnTime;

/**
 * Enable refreshing based on distance since the last dimension request. Does
 * nothing if automatic updates should not be enabled, ie. when the dimension is
 * outdated, the refresh distance is set to infinite or the refresh URL is not set.
 */
- (void)startRefreshingOnDistance;

/**
 * Disable refreshing based on distance.
 */
- (void)stopRefreshingOnDistance;

/**
 * Check whether the distance is large enough to trigger a refresh.
 */
- (void)refreshOnDistanceIfNecessary;

/**
 * Start scanning for QR codes. Initializes the QR code scanner itself, but does
 * not change the user interface.
 */
- (void)startScanning;

/**
 * Stop scanning for QR codes. Disabled and frees up resources used by the
 * scanner, but does not change the user interface.
 */
- (void)stopScanning;

/**
 * Handle an overlay being tapped. Perform the corresponding action.
 * @param view the view for the overlay that was tapped.
 */
- (void)didTapOverlay:(AROverlayView *)view;

/**
 * Handle a feature being tapped. Perform the corresponding action.
 * @param view the view for the feature that was tapped.
 */
- (void)didTapFeature:(ARFeatureView *)view;

/**
 * Handle the menu button being tapped.
 */
- (void)didTapMenuButton;

/**
 * Handle the cancel button being tapped.
 */
- (void)didTapCancelButton;

/**
 * Handle the about window's close button being tapped.
 */
- (void)didTapAboutControllerCloseButton;
	
/**
 * Perform an action, which can lead to an URL being opened, a new dimension
 * being loaded or the same dimension being reloaded.
 * @param action the action to perform
 * @param source the identifier of the object that triggered this action.
 */
- (void)performAction:(ARAction *)action source:(NSString *)source;

/**
 * Change the current state of the application. This function controls the state
 * machine, which means that it calls the didLeaveState, then sets the new
 * state, and finally calls didEnterState for the newly entered state. If the
 * new state is equal to the current state, neither function is called.
 * @param state the new state.
 */
- (void)setState:(int)state;

/**
 * Handle a state change, right after this state is entered. This function
 * enables features and views, so that they match what is necessary
 * in the new state. This function can assume that all features and view used by
 * other views are already disabled or hidden.
 * @param state the newly entered state.
 */
- (void)didEnterState:(int)state;

/**
 * Handle a state change, right before this state is left. This function
 * disables features and views unique to this state, so that the new state can
 * assume there is nothing but a bare camera view.
 * @param state the state that will be left.
 */
- (void)didLeaveState:(int)state;

@end


@implementation ARMainController

@synthesize pendingDimensionURL;
@synthesize dimension;
@synthesize featureContainerView;
@synthesize overlayContainerView;
@synthesize radarView;
@synthesize mapView;

@synthesize displayLink;

@synthesize dimensionRequest;
@synthesize refreshTimer;
@synthesize refreshTime;
@synthesize refreshingOnDistance;
@synthesize refreshLocation;

#pragma mark NSObject

- (id)init {
	return [self initWithURL:nil];
}

- (id)initWithURL:(NSURL *)aURL {
	if (self = [super init]) {
		if (aURL) {
			pendingDimensionURL = [aURL retain];
			
			DebugLog(@"Got dimension URL, waiting for location fix");
		}
		else if ([[NSUserDefaults standardUserDefaults] objectForKey:DIMENSION_URL_DEFAULTS_KEY]) {
			pendingDimensionURL = [[NSURL alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:DIMENSION_URL_DEFAULTS_KEY]];
			
			DebugLog(@"Using dimension URL from user defaults, waiting for location fix");
		}
		
		[self setWantsFullScreenLayout:YES];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[displayLink invalidate];
	[refreshTimer invalidate];
	[scanTimer invalidate];
	
	[pendingDimensionURL release];
	[dimension release];
	[cameraViewController release];
	[displayLink release];
	[dimensionRequest release];
	[assetManager release];
	[spatialStateManager release];
	[refreshTimer release];
	[refreshLocation release];
	[scanTimer release];
	[scanner release];
	[refreshTime release];
	
	[super dealloc];
}

#pragma mark UIViewController

- (void)loadView {
	[super loadView];
	UIView *view = [self view];
	CGRect bounds = [view bounds];
	CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
	
	// We want our view to be fully opaque for hit testing to work as expected
	[view setBackgroundColor:[UIColor blackColor]];

	if ([self cameraViewController]) {
		UIView *cameraViewControllerView = [[self cameraViewController] view];
		[cameraViewControllerView setBounds:CGRectMake(0, 0, 320, 480)];
		[cameraViewControllerView setAutoresizingMask:UIViewAutoresizingNone];
		[view addSubview:cameraViewControllerView];
	}

	featureContainerView = [[ARFeatureContainerView alloc] init];
	[featureContainerView setBounds:CGRectMake(0, 0, 320, 480)];
	[featureContainerView setAutoresizingMask:UIViewAutoresizingNone];
	[featureContainerView setHidden:YES];
	[view addSubview:featureContainerView];
	[featureContainerView release];
	
	radarView = [[ARRadarView alloc] init];
	CGSize radarSize = [radarView sizeThatFits:CGSizeZero];
	[radarView setFrame:CGRectMake(CGRectGetMinX(bounds) + MARGIN, CGRectGetMaxY(bounds) - MARGIN - radarSize.width, radarSize.width, radarSize.height)];
	[radarView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
	[radarView setHidden:YES];
	[view addSubview:radarView];
	[radarView release];
	
	overlayContainerView = [[AROverlayContainerView alloc] init];
	[overlayContainerView setFrame:bounds];
	[overlayContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[overlayContainerView setHidden:YES];
	[view addSubview:overlayContainerView];
	[overlayContainerView release];
	
	UIImage *dimensionWarningImage = [UIImage imageNamed:@"DimensionWarning.png"];
	CGRect dimensionWarningFrame = CGRectMake(CGRectGetMinX(bounds) + MARGIN, CGRectGetMinY(bounds) + statusBarHeight + MARGIN, dimensionWarningImage.size.width, dimensionWarningImage.size.height);
	dimensionWarningView = [[UIImageView alloc] initWithImage:dimensionWarningImage];
	[dimensionWarningView setFrame:dimensionWarningFrame];
	[dimensionWarningView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
	[dimensionWarningView setHidden:YES];
	[view addSubview:dimensionWarningView];
	[dimensionWarningView release];
	
	UIImage *locationWarningImage = [UIImage imageNamed:@"LocationWarning.png"];
	CGRect locationWarningFrame = CGRectMake(CGRectGetMaxX(dimensionWarningFrame) + MARGIN, CGRectGetMinY(bounds) + statusBarHeight + MARGIN, locationWarningImage.size.width, locationWarningImage.size.height);
	locationWarningView = [[UIImageView alloc] initWithImage:locationWarningImage];
	[locationWarningView setFrame:locationWarningFrame];
	[locationWarningView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
	[locationWarningView setHidden:YES];
	[view addSubview:locationWarningView];
	[locationWarningView release];
	
	UIImage *orientationWarningImage = [UIImage imageNamed:@"OrientationWarning.png"];
	CGRect orientationWarningFrame = CGRectMake(CGRectGetMaxX(locationWarningFrame) + MARGIN, CGRectGetMinY(bounds) + statusBarHeight + MARGIN, orientationWarningImage.size.width, orientationWarningImage.size.height);
	orientationWarningView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OrientationWarning.png"]];
	[orientationWarningView setFrame:orientationWarningFrame];
	[orientationWarningView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
	[orientationWarningView setHidden:YES];
	[view addSubview:orientationWarningView];
	[orientationWarningView release];
	
	mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
	mapView.showsUserLocation = YES;
	mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[mapView setHidden:YES];
	[view addSubview:mapView];
	[mapView release];
	
	menuButton = [[ARButton alloc] init];
	[menuButton setFrame:CGRectMake(CGRectGetMaxX(bounds) - MARGIN - MENU_BUTTON_WIDTH, CGRectGetMaxY(bounds) - MARGIN - BUTTON_HEIGHT, MENU_BUTTON_WIDTH, BUTTON_HEIGHT)];
	[menuButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
	[menuButton setImage:[UIImage imageNamed:MENU_BUTTON_IMAGE] forState:UIControlStateNormal];
	[menuButton addTarget:self action:@selector(didTapMenuButton) forControlEvents:UIControlEventTouchUpInside];
	[menuButton setHidden:YES];
	[view addSubview:menuButton];
	[menuButton release];
	
	closeButton = [[ARButton alloc] init];
	[closeButton setFrame:CGRectMake(CGRectGetMaxX(bounds) - MARGIN - MENU_BUTTON_WIDTH, CGRectGetMaxY(bounds) - MARGIN - BUTTON_HEIGHT, MENU_BUTTON_WIDTH, BUTTON_HEIGHT)];
	[closeButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
	[closeButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
	[closeButton addTarget:self action:@selector(refreshDimension) forControlEvents:UIControlEventTouchUpInside];
	[closeButton setHidden:YES];
	[view addSubview:closeButton];
	[closeButton release];
	
	cancelButton = [[ARButton alloc] init];
	[cancelButton setFrame:CGRectMake(CGRectGetMaxX(bounds) - MARGIN - CANCEL_BUTTON_WIDTH, CGRectGetMaxY(bounds) - MARGIN - BUTTON_HEIGHT, CANCEL_BUTTON_WIDTH, BUTTON_HEIGHT)];
	[cancelButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
	[cancelButton setTitle:NSLocalizedString(@"Cancel", @"main controller button") forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(didTapCancelButton) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton setHidden:YES];
	[view addSubview:cancelButton];
	[cancelButton release];
	
	[self createOverlayViews];
	[self createFeatureViews];
	[self updateAnnotations];
	
	// Use a display link to sync up with the screen, so that we don't update the screen more than necessary
	CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateWithDisplayLink:)];
	[link setPaused:YES];
	[link setFrameInterval:FRAME_INTERVAL];
	[self setDisplayLink:link];
	[link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[cameraViewController release];
	cameraViewController = nil;
	featureContainerView = nil;
	radarView = nil;
	mapView = nil;
	overlayContainerView = nil;
	scannerOverlayView = nil;
	dimensionWarningView = nil;
	locationWarningView = nil;
	orientationWarningView = nil;
	menuButton = nil;
	cancelButton = nil;
	
	[self setDisplayLink:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[self cameraViewController] viewWillAppear:animated];
	
	// We don't know our orientation in loadView, so update here
	[self updateWithInterfaceOrientation:[self interfaceOrientation] prepareForAnimation:NO];

	// Transition to the dimension state
	[self setState:STATE_DIMENSION];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[self cameraViewController] viewDidAppear:animated];
	
	[self ensureStatusBarVisible];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[self cameraViewController] viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[[self cameraViewController] viewDidDisappear:animated];

	[self setState:STATE_HIDDEN];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;// UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[self updateWithInterfaceOrientation:interfaceOrientation prepareForAnimation:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self updateWithInterfaceOrientation:[self interfaceOrientation] prepareForAnimation:NO];
}

#pragma mark UIApplicationNotifications

- (void)applicationWillResignActive:(NSNotification *)notification {
	switch (currentState) {
		case STATE_DIMENSION:
			[self stopRefreshingOnTime];
			[self stopRefreshingOnDistance];
			[[self displayLink] setPaused:YES];
			break;
			
		case STATE_QR:
			[self stopScanning];
			break;
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	switch (currentState) {
		case STATE_DIMENSION:
			if (dimension) {
				[self startRefreshingOnTime];
				[self startRefreshingOnDistance];
			}
			[[self displayLink] setPaused:NO];
			break;
			
		case STATE_QR:
			[self startScanning];
			break;
	}
}

#pragma mark UIAlertViewDelegate

- (void)willPresentAlertView:(UIAlertView *)alertView {
	switch (currentState) {
		case STATE_DIMENSION:
			[self stopRefreshingOnTime];
			[self stopRefreshingOnDistance];
			break;
			
		case STATE_QR:
			[self stopScanning];
			break;
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	switch (currentState) {
		case STATE_DIMENSION:
			[self startRefreshingOnTime];
			[self startRefreshingOnDistance];
			break;
			
		case STATE_QR:
			[self startScanning];
			break;
	}
}

#pragma mark CADisplayLink

- (void)updateWithDisplayLink:(CADisplayLink *)sender {
	// If the screen has been invalidated, update it
	[self updateIfNeeded];
}

#pragma mark ARDimensionRequestDelegate

- (void)dimensionRequest:(ARDimensionRequest *)request didFinishWithDimension:(ARDimension *)aDimension {
	// Save the dimension
	[self setDimension:aDimension];
	
	// Forget the dimension request
	[self setDimensionRequest:nil];
	
	dimensionReliable = YES;

	// Cancel loading any assets before we start reloading them in the create... methods below
	[[self assetManagerIfAvailable] cancelLoadingAllAssets];
	
	[menuButton setHidden:NO];
	[closeButton setHidden:YES];
	
	[self createOverlayViews];
	[self createFeatureViews];
	[self updateAnnotations];
	
	// Set the refresh time
	if ([[self dimension] refreshTime] == ARDimensionRefreshTimeInfinite) {
		[self setRefreshTime:nil];
	}
	else {
		[self setRefreshTime:[NSDate dateWithTimeIntervalSinceNow:[[self dimension] refreshTime]]];
	}
	
	[self startRefreshingOnTime];
	[self startRefreshingOnDistance];
	
	// Remember this URL for when the app restarts
	// Note: don't remember file URLs, those change when the application's unique identifier on the device changes
	if (![[request url] isFileURL]) {
		[[NSUserDefaults standardUserDefaults] setObject:[[request url] absoluteString] forKey:DIMENSION_URL_DEFAULTS_KEY];
	}
}

- (void)dimensionRequest:(ARDimensionRequest *)request didFailWithError:(NSError *)error {
	// Forget the dimension request
	[self setDimensionRequest:nil];

	dimensionReliable = NO;
	
	[self startRefreshingOnTime];
	[self startRefreshingOnDistance];

	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setDelegate:self];
	if ([request type] == ARDimensionRequestTypeInit) {
		[alert setTitle:NSLocalizedString(@"Dimension failed to load", @"main controller alert title")];
	}
	else {
		[alert setTitle:NSLocalizedString(@"Dimension failed to refresh, automatic refreshing disabled", @"main controller alert title")];
	}
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
	// Find overlays that need this data
	// TODO: Refactor
	for (UIView *view in [overlayContainerView subviews]) {
		if ([view conformsToProtocol:@protocol(ARAssetDataUser)]) {
			id <ARAssetDataUser> user = (id <ARAssetDataUser>)view;
			if ([[user assetIdentifiersForNeededData] containsObject:[asset identifier]]) {
				[user setDataUnavailableForAssetIdentifier:[asset identifier]];
			}
		}
	}
	
	// Find features that need this data
	// TODO: Refactor
	for (UIView *view in [featureContainerView subviews]) {
		if ([view conformsToProtocol:@protocol(ARAssetDataUser)]) {
			id <ARAssetDataUser> user = (id <ARAssetDataUser>)view;
			if ([[user assetIdentifiersForNeededData] containsObject:[asset identifier]]) {
				[user setDataUnavailableForAssetIdentifier:[asset identifier]];
			}
		}
	}
}

#pragma mark ARSpatialStateManagerDelegate

- (void)spatialStateManagerDidUpdate:(ARSpatialStateManager *)manager {
	// Invalidate the screen, the display link will take care of actually updating the screen when needed
	[self setNeedsUpdate];
	
	// If we have a location and orientation fix, send a request for any pending URL
	if ([[manager spatialState] isLocationAvailable] && [[manager spatialState] isOrientationAvailable]) {
		if ([self pendingDimensionURL]) {
			[self startDimensionRequestWithURL:[self pendingDimensionURL] type:ARDimensionRequestTypeInit source:nil];
			[self setPendingDimensionURL:nil];
		}
	}
}

- (void)spatialStateManagerLocationDidUpdate:(ARSpatialStateManager *)manager {
	ARSpatialState *spatialState = [manager spatialState];
	if ([spatialState isLocationAvailable]) {
		[manager setEFToECEFSpaceOffset:[spatialState locationInECEFSpace]];
		
		[self refreshOnDistanceIfNecessary];
	}
}

#pragma mark NSTimerInvocation

- (void)refreshTimerDidFire:(NSTimer *)aTimer {
	[self startDimensionRequestWithURL:[[self dimension] refreshURL] type:ARDimensionRequestTypeTimeRefresh source:nil];
}

- (void)scanTimerDidFire {
	ZBarImage *barImage;
	
	// Note: use of private API
	CGImageRef screenImage = UIGetScreenImage();
	barImage = [[ZBarImage alloc] initWithCGImage:screenImage];
	// Apparently we need to release the screen image, otherwise it leaks
	CGImageRelease(screenImage);
	
	[scanner scanImage:barImage];
	
	ZBarSymbol *sym = nil;
	ZBarSymbolSet *results = scanner.results;
	results.filterSymbols = NO;
	for (ZBarSymbol *s in results)
		if (!sym || sym.quality < s.quality)
			sym = s;
	
	if (sym) {
		NSURL *url = [NSURL URLWithString:[sym data]];
		
		// Flash the screen
		[ARScannerFlash flashWithBeepTone:YES];
		
		if (!([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"gamaray"])) {
			UIAlertView *alert = [[UIAlertView alloc] init];
			[alert setDelegate:self];
			[alert setTitle:NSLocalizedString(@"Unrecognized QR code", @"main controller alert title")];
			[alert setMessage:NSLocalizedString(@"The scanned QR code does not resolve to a dimension.", @"main controller alert message")];
			[alert addButtonWithTitle:NSLocalizedString(@"Close", @"main controller alert button")];
			[alert show];
			[alert release];
		}
		else {
			DebugLog(@"Loading dimension by QR code: %@", [sym data]);
			
			[[self dimensionRequest] cancel];
			[self setDimensionRequest:nil];
			
			[self setDimension:nil];
			[self createOverlayViews];
			[self createFeatureViews];
			
			if ([[[self spatialStateManager] spatialState] isLocationAvailable] && [[[self spatialStateManager] spatialState] isOrientationAvailable]) {
				[self startDimensionRequestWithURL:url type:ARDimensionRequestTypeInit source:nil];
			}
			else {
				[self setPendingDimensionURL:url];
			}
			
			[self setState:STATE_DIMENSION];
		}
	}
	
	[barImage release];
}

#pragma mark UIActionSheetDelegate

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
	switch (currentState) {
		case STATE_DIMENSION:
			[self stopRefreshingOnTime];
			[self stopRefreshingOnDistance];
			break;
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == menuButtonIndices.about) {
		ARAboutController *controller = [[ARAboutController alloc] init];
		[[controller navigationItem] setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"about controller button") style:UIBarButtonItemStyleBordered target:self action:@selector(didTapAboutControllerCloseButton)] autorelease]];
		
		// Wrap in a navigation controller
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
		[self presentModalViewController:navigationController animated:YES];
		[navigationController release];
		
		[controller release];
		
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	}
	else if (buttonIndex == menuButtonIndices.refresh) {
		[self refreshDimension];
	}
	else if (buttonIndex == menuButtonIndices.map) {
		if (mapView.hidden) {
			[mapView setHidden:NO];
			
			if ([mapView isUserLocationVisible]) {  
				int mapRadius = dimension.radarRadius;
				MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, mapRadius, mapRadius);
				// for correcting map aspect view
				[mapView setRegion:[mapView regionThatFits:region] animated:YES]; 
			}
			
		} else {
			[mapView setHidden:YES];
		}
	}
	else if (buttonIndex == menuButtonIndices.qr) {
		[mapView setHidden:YES];
		[self setState:STATE_QR];
	}
	
	switch (currentState) {
		case STATE_DIMENSION:
			[self startRefreshingOnTime];
			[self startRefreshingOnDistance];
			break;
	}
}

-(void) updateAnnotations {
		DebugLog(@"Remove annotations");
		NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10];
		for (id annotation in mapView.annotations) {
			if (annotation != mapView.userLocation) {
				DebugLog(@"   Remove annotation");
				[toRemove addObject:annotation];
			}
		}
		[mapView removeAnnotations:toRemove];
		
		DebugLog(@"locations: %@", dimension.locations);
		for (ARLocation *location in dimension.locations) {
			ARLocationAnnotation *locationAnnotation = [[ARLocationAnnotation alloc] initWithLocation:location];
			DebugLog(@"Adding location %@", location);
			[mapView addAnnotation:locationAnnotation];
		}
		
		DebugLog(@"features: %@", dimension.features);
		for (ARFeature *feature in dimension.features) {
			ARLocationAnnotation *featureAnnotation = [[ARLocationAnnotation alloc] initWithLocation:feature.location];
			DebugLog(@"Adding location %@", feature.location);
			[mapView addAnnotation:featureAnnotation];
		}
}

#pragma mark ARMainController

- (UIImagePickerController *)cameraViewController {
	// Lazily create camera view controller, if necessary
	if (cameraViewController == nil) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			cameraViewController = [[UIImagePickerController alloc] init];
			[cameraViewController setSourceType:UIImagePickerControllerSourceTypeCamera];
			[cameraViewController setShowsCameraControls:NO];
			[cameraViewController setCameraViewTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(CAMERA_VIEW_SCALE, CAMERA_VIEW_SCALE), 0, CAMERA_CONTROLS_HEIGHT / 2)];
		}
	}
	return cameraViewController;
}

- (ARScannerOverlayView *)scannerOverlayView {
	if (scannerOverlayView == nil) {
		scannerOverlayView = [[ARScannerOverlayView alloc] init];
		[scannerOverlayView setFrame:[[self view] bounds]];
		[scannerOverlayView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[[self view] addSubview:scannerOverlayView];
	}
	return scannerOverlayView;
}

- (void)setDisplayLink:(CADisplayLink *)aLink {
	if (displayLink != aLink) {
		// Remove the existing link from the runloop
		[displayLink invalidate];
		
		[displayLink release];
		displayLink = [aLink retain];
	}
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

- (void)setScanTimer:(NSTimer *)aTimer {
	if (scanTimer != aTimer) {
		// Unschedule the existing timer from the runloop
		[scanTimer invalidate];
		
		[scanTimer release];
		scanTimer = [aTimer retain];
	}
}

- (void)updateWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation prepareForAnimation:(BOOL)animation {
	CGFloat screenRotation = 0.f;
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			if (animation) {
				// This ensures the animation will go the right way around
				screenRotation = -1e-6f;
			}
			else {
				screenRotation = 0.f;
			}
			break;
			
		case UIInterfaceOrientationLandscapeRight:
			screenRotation = .5f * M_PI;
			break;
			
		case UIInterfaceOrientationPortraitUpsideDown:
			if (animation) {
				// This ensures the animation will go the right way around
				screenRotation = -M_PI + 1e-6f;
			}
			else {
				screenRotation = M_PI;
			}
			break;
			
		case UIInterfaceOrientationLandscapeLeft:
			screenRotation = -.5f * M_PI;
			break;
	}
	
	// Since the camera view, feature container and radar all assume the device axes are the same as the screen axes, we rotate them as the interface orientation changes
	CGRect bounds = [[self view] bounds];
	CGPoint center = CGPointMake(roundf(CGRectGetMidX(bounds)), roundf(CGRectGetMidY(bounds)));
	CGAffineTransform transform = CGAffineTransformMakeRotation(-screenRotation);
	
	UIView *cameraView = [[self cameraViewController] view];
	[cameraView setCenter:center];
	[cameraView setTransform:transform];
	
	[featureContainerView setCenter:center];
	[featureContainerView setTransform:transform];
	
	[radarView setTransform:transform];
}

- (void)ensureStatusBarVisible {
	// It only works if we do this in a next iteration of the run loop
	[self performSelectorOnMainThread:@selector(makeStatusBarVisible) withObject:nil waitUntilDone:NO];
}

- (void)makeStatusBarVisible {
	UIApplication *application = [UIApplication sharedApplication];
	[application setStatusBarHidden:NO];
	
	// Apparently the following line is what forces the status bar to appear after the camera controller did its magic to it
	[application setStatusBarStyle:[application statusBarStyle]];
}

- (void)createOverlayViews {
	// Remove all existing overlay views
	UIView *view;
	while (view = [[overlayContainerView subviews] lastObject]) {
		[view removeFromSuperview];
	}
	
	for (AROverlay *overlay in [dimension overlays]) {
		if ([overlay isKindOfClass:[ARHTMLOverlay class]]) {
			[menuButton setHidden:YES];
			[closeButton setHidden:NO];
		}
		AROverlayView *view = [AROverlayView viewForOverlay:overlay];
		[[view layer] setPosition:[overlay origin]];
		[overlayContainerView addSubview:view];
		
		// Register for events if necessary
		if ([overlay action]) {
			[view addTarget:self action:@selector(didTapOverlay:) forControlEvents:UIControlEventTouchUpInside];
		}
		
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
		
		// Register for events if necessary
		if ([feature action]) {
			// Note: at this time, the controls are unable to determine correctly whether a touch was inside their bounds or not, so subscribe to either event
			[view addTarget:self action:@selector(didTapFeature:) forControlEvents:UIControlEventTouchUpInside];
			[view addTarget:self action:@selector(didTapFeature:) forControlEvents:UIControlEventTouchUpOutside];
		}
		
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
	
	[radarView setFeatures:[dimension features]];
	[radarView setRadius:[dimension radarRadius]];
	
	[self updateFeatureViews];
}

- (void)updateFeatureViews {
	ARSpatialState *spatialState = [spatialStateManager spatialState];
	[featureContainerView updateWithSpatialState:spatialState usingRelativeAltitude:[dimension relativeAltitude]];
	[radarView updateWithSpatialState:spatialState usingRelativeAltitude:[dimension relativeAltitude]];
}

- (void)setNeedsUpdate {
	needsUpdate = YES;
}

- (void)updateIfNeeded {
	ARSpatialState *spatialState = [spatialStateManager spatialState];
	[dimensionWarningView setHidden:[self dimension] != nil && dimensionReliable];
	[locationWarningView setHidden:[spatialState isLocationAvailable] && [spatialState isLocationReliable]];
	[orientationWarningView setHidden:[spatialState isOrientationAvailable] && [spatialState isOrientationReliable]];
	
	if (needsUpdate) {
		needsUpdate = NO;
		
		[self updateFeatureViews];
	}
}

- (void)startDimensionRequestWithURL:(NSURL *)aURL type:(ARDimensionRequestType)type source:(NSString *)source {
	DebugLog(@"URL: %@", aURL);
	NSAssert(aURL, @"Expected non-nil URL.");
	NSAssert([[spatialStateManager spatialState] isLocationAvailable], @"Expected location to be available");
	NSAssert([[spatialStateManager spatialState] isOrientationAvailable], @"Expected orientation to be available");
	if([self dimensionRequest] != nil) {
		[[self dimensionRequest] cancel];
	}
	
	// Cancel loading any assets
	[[self assetManagerIfAvailable] cancelLoadingAllAssets];
	
	// Make sure to kill any timer, since we don't want it firing when we're already refreshing
	[self stopRefreshingOnTime];
	[self stopRefreshingOnDistance];

	ARDimensionRequest *request = [[ARDimensionRequest alloc] initWithURL:aURL spatialState:[[self spatialStateManager] spatialState] type:type];
	[request setSource:source];
	[request setScreenSize:[[self view] bounds].size];
	[request setDelegate:self];
	[self setDimensionRequest:request];
	[request release];

	[request start];
	
	// Reset refresh time
	[self setRefreshTime:nil];
	
	// Register the location we sent to the server
	[self setRefreshLocation:[[request spatialState] location]];
}

- (void)startRefreshingOnTime {
	if ([self dimensionRequest] != nil || !dimensionReliable || ![[self dimension] refreshURL] || [self refreshTime] == nil) {
		[self setRefreshTimer:nil];
		
		DebugLog(@"Dimension refresh timer not scheduled");
	}
	else {
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:ARMax(0., [[self refreshTime] timeIntervalSinceNow]) target:self selector:@selector(refreshTimerDidFire:) userInfo:nil repeats:NO];
		[self setRefreshTimer:timer];
		
		DebugLog(@"Scheduling dimension refresh timer with timeout %fs", ARMax(0., [[self refreshTime] timeIntervalSinceNow]));
	}
}

- (void)stopRefreshingOnTime {
	[self setRefreshTimer:nil];
}

- (void)startRefreshingOnDistance {
	if ([self dimensionRequest] != nil || !dimensionReliable || ![[self dimension] refreshURL] || [[self dimension] refreshDistance] == ARDimensionRefreshDistanceInfinite) {
		[self setRefreshingOnDistance:NO];
	}
	else {
		[self setRefreshingOnDistance:YES];
		[self refreshOnDistanceIfNecessary];
	}
}

- (void)stopRefreshingOnDistance {
	[self setRefreshingOnDistance:NO];
}

- (void)refreshOnDistanceIfNecessary {
	ARSpatialState *spatialState = [[self spatialStateManager] spatialState];
	
	// Deal with the refresh location
	if ([self isRefreshingOnDistance]) {
		// If we don't have a refresh location yet, set it now
		if (![self refreshLocation]) {
			[self setRefreshLocation:[spatialState location]];
		}
		else if ([[spatialState location] straightLineDistanceToLocation:[self refreshLocation]] >= [dimension refreshDistance]) {
			[self startDimensionRequestWithURL:[[self dimension] refreshURL] type:ARDimensionRequestTypeDistanceRefresh source:nil];
			[self stopRefreshingOnDistance];
		}
	}
}

- (void)startScanning {
	[scanner release];
	scanner = [[ZBarImageScanner alloc] init];
	
	// Only scan QR codes, makes the scanner do less work
	[scanner setSymbology:0 config:ZBAR_CFG_ENABLE to:NO];
	[scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:YES];

	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:SCAN_TIMER_INTERVAL target:self selector:@selector(scanTimerDidFire) userInfo:nil repeats:YES];
	[self setScanTimer:timer];
}

- (void)stopScanning {
	[self setScanTimer:nil];
	
	[scanner release];
	scanner = nil;
}

- (void)didTapOverlay:(AROverlayView *)view {
	AROverlay *overlay = [view overlay];
	[self performAction:[overlay action] source:[overlay identifier]];
}

- (void)didTapFeature:(ARFeatureView *)view {
	ARFeature *feature = [view feature];
	[self performAction:[feature action] source:[feature identifier]];
}

- (void) refreshDimension {
	[self startDimensionRequestWithURL:[[self dimension] refreshURL] type:ARDimensionRequestTypeInit source:nil];
}

- (void)didTapMenuButton {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
	[actionSheet setDelegate:self];
	
	// For informational purposes, show the name of the dimension as the menu title
	if ([self dimension]) {
		NSString *name = [[self dimension] name] ? [[self dimension] name] : NSLocalizedString(@"Untitled", @"unknown dimension name");
		[actionSheet setTitle:[NSString stringWithFormat:NSLocalizedString(@"Current Dimension: %@",  @"action sheet title"), name]];
	}
	else {
		[actionSheet setTitle:NSLocalizedString(@"No Dimension Loaded", @"action sheet title")];
	}
	
	// Keep track of the indices of the buttons we add
	signed char index = 0;
	
	// Add about button
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Info", @"actionsheet button")];
	menuButtonIndices.about = index++;
	
	// Add refresh button and map
	if (![[self dimension] refreshURL]) {
		menuButtonIndices.refresh = -1;
		menuButtonIndices.map = -1;
	}
	else {
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Refresh", @"actionsheet button")];
		menuButtonIndices.refresh = index++;
		if (mapView.hidden) {
			[actionSheet addButtonWithTitle:NSLocalizedString(@"Map", @"actionsheet button")];
		} else {
			[actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", @"actionsheet button")];			
		}
		menuButtonIndices.map = index++;
	}

	// Add QR code button, if appropriate
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Scan QR Code", @"actionsheet button")];
		menuButtonIndices.qr = index++;
	}
	else {
		menuButtonIndices.qr = -1;
	}
	
	// Add cancel button
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"actionsheet button")];
	menuButtonIndices.cancel = index++;
	[actionSheet setCancelButtonIndex:menuButtonIndices.cancel];

	[actionSheet showInView:[self view]];
	[actionSheet release];
	
	#pragma unused(index)
}

- (void)didTapCancelButton {
	[self setState:STATE_DIMENSION];
}

- (void)didTapAboutControllerCloseButton {
	[self dismissModalViewControllerAnimated:YES];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
}

- (void)performAction:(ARAction *)action source:(NSString *)source {
	switch ([action type]) {
		case ARActionTypeRefresh:
			[self startDimensionRequestWithURL:[[self dimension] refreshURL] type:ARDimensionRequestTypeActionRefresh source:source];
			break;
			
		case ARActionTypeDimension:
			NSAssert([action URL] != nil, @"Expected non-nil URL.");
			[self startDimensionRequestWithURL:[action URL] type:ARDimensionRequestTypeInit source:nil];
			break;
			
		case ARActionTypeURL:
			NSAssert([action URL] != nil, @"Expected non-nil URL.");
			[[UIApplication sharedApplication] openURL:[action URL]];
			break;
			
		default:
			DebugLog(@"Unrecognized action type %d", [action type]);
			break;
	}
}

- (void)setState:(int)state {
	if (state != currentState) {
		int oldState = currentState;
		currentState = state;
		[self didLeaveState:oldState];
		[self didEnterState:currentState];
	}
}

- (void)didEnterState:(int)state {
	DebugLog(@"Entering state %d", state);
	
	switch (state) {
		case STATE_DIMENSION:
			if ([self dimension]) {
				[self startRefreshingOnTime];
				[self startRefreshingOnDistance];
			}
			[[self spatialStateManager] startUpdating];
			[featureContainerView setHidden:NO];
			[overlayContainerView setHidden:NO];
			[radarView setHidden:NO];
			[menuButton setHidden:NO];
			[displayLink setPaused:NO];
			
			// Force an initial update
			[self setNeedsUpdate];
			
			[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
			break;
			
		case STATE_QR:
			[[self scannerOverlayView] setHidden:NO];
			[cancelButton setHidden:NO];
			[self startScanning];
			break;
	}
}

- (void)didLeaveState:(int)state {
	DebugLog(@"Leaving state %d", state);
	
	switch (state) {
		case STATE_DIMENSION:
			[self stopRefreshingOnTime];
			[self stopRefreshingOnDistance];
			[spatialStateManager stopUpdating];
			[dimensionRequest cancel];
			[featureContainerView setHidden:YES];
			[overlayContainerView setHidden:YES];
			[radarView setHidden:YES];
			[dimensionWarningView setHidden:YES];
			[locationWarningView setHidden:YES];
			[orientationWarningView setHidden:YES];
			[menuButton setHidden:YES];
			[displayLink setPaused:YES];
			
			[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
			break;
			
		case STATE_QR:
			[[self scannerOverlayView] setHidden:YES];
			[cancelButton setHidden:YES];
			[self stopScanning];
			break;
	}
}

@end
