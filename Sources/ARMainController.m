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
#import "ARFeature.h"
#import "ARFeatureContainerView.h"
#import "ARFeatureView.h"
#import "ARAction.h"
#import "ARSpatialStateManager.h"
#import "ARWGS84.h"
#import "ARLocation.h"
#import "ARRadarView.h"
#import "ARButton.h"
#import "ARAssetDataUser.h"
#import <QuartzCore/QuartzCore.h>
#import <zbar/ZBarImageScanner.h>


#define DIMENSION_URL_DEFAULTS_KEY @"dimensionURL"

#define SCREEN_SIZE_X 320
#define SCREEN_SIZE_Y 480
#define CAMERA_CONTROLS_HEIGHT (53.)
#define CAMERA_VIEW_SCALE (SCREEN_SIZE_Y / (SCREEN_SIZE_Y - CAMERA_CONTROLS_HEIGHT))

// Fraction of the refresh rate of the screen at which to update
// Note: a frame interval of 2 results in 30 FPS and seems smooth enough
#define FRAME_INTERVAL 2

// Time interval between two QR scans.
#define SCAN_TIMER_INTERVAL 1

#define MENU_BUTTON_QR 0
#define MENU_BUTTON_CANCEL 1

#define STATE_STARTING 0
#define STATE_DIMENSION 1
#define STATE_QR 2


// expose undocumented API
CGImageRef UIGetScreenImage(void);


@interface ARMainController ()

@property(nonatomic, retain) NSURL *pendingDimensionURL;
@property(nonatomic, retain) ARDimension *dimension;
@property(nonatomic, readonly) UIImagePickerController *cameraViewController;
@property(nonatomic, readonly) ARFeatureContainerView *featureContainerView;
@property(nonatomic, readonly) AROverlayContainerView *overlayContainerView;
@property(nonatomic, readonly) ARRadarView *radarView;

@property(nonatomic, retain) CADisplayLink *displayLink;

@property(nonatomic, retain) ARDimensionRequest *dimensionRequest;
@property(nonatomic, readonly) ARAssetManager *assetManager;
@property(nonatomic, readonly) ARAssetManager *assetManagerIfAvailable;
@property(nonatomic, readonly) ARSpatialStateManager *spatialStateManager;
@property(nonatomic, retain) NSTimer *refreshTimer;
@property(nonatomic, getter=isRefreshingOnDistance) BOOL refreshingOnDistance;
@property(nonatomic, retain) ARLocation *refreshLocation;

- (void)ensureStatusBarVisible;

- (void)createOverlayViews;
- (void)createFeatureViews;
- (void)updateFeatureViews;

- (void)setNeedsUpdate;
- (void)updateIfNeeded;

- (void)startDimensionRequestWithURL:(NSURL *)aURL type:(ARDimensionRequestType)type source:(NSString *)source;
- (void)startRefreshingOnTime;
- (void)stopRefreshingOnTime;
- (void)startRefreshingOnDistanceResetLocation:(BOOL)reset;
- (void)stopRefreshingOnDistance;
- (void)startScanning;
- (void)stopScanning;

- (void)performAction:(ARAction *)action source:(NSString *)source;

- (void)setState:(int)state;
- (void)didEnterState:(int)state;
- (void)didLeaveState:(int)state;

@end


@implementation ARMainController

@synthesize pendingDimensionURL;
@synthesize dimension;
@synthesize featureContainerView;
@synthesize overlayContainerView;
@synthesize radarView;

@synthesize displayLink;

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
	
	[super dealloc];
}

#pragma mark UIViewController

- (void)loadView {
	[super loadView];
	UIView *view = [self view];
	
	// We want our view to be fully opaque for hit testing to work as expected
	[view setBackgroundColor:[UIColor blackColor]];
	
#if !TARGET_IPHONE_SIMULATOR
	[view addSubview:[[self cameraViewController] view]];
#endif

	// We are setting the feature container's origin to the center of the screen
	featureContainerView = [[ARFeatureContainerView alloc] init];
	[featureContainerView setCenter:CGPointMake(SCREEN_SIZE_X / 2., SCREEN_SIZE_Y / 2.)];
	[featureContainerView setBounds:CGRectMake(-SCREEN_SIZE_X / 2., -SCREEN_SIZE_Y / 2., SCREEN_SIZE_X, SCREEN_SIZE_Y)];
	[view addSubview:featureContainerView];
	[featureContainerView setHidden:YES];
	[featureContainerView release];
	
	radarView = [[ARRadarView alloc] init];
	[radarView setFrame:CGRectMake(10, SCREEN_SIZE_Y - 100 - 10, 100, 100)];
	[view addSubview:radarView];
	[radarView setHidden:YES];
	[radarView release];
	
	overlayContainerView = [[AROverlayContainerView alloc] init];
	[overlayContainerView setFrame:CGRectMake(0, 0, SCREEN_SIZE_X, SCREEN_SIZE_Y)];
	[view addSubview:overlayContainerView];
	[overlayContainerView setHidden:YES];
	[overlayContainerView release];
	
	menuButton = [[ARButton alloc] init];
	[menuButton setFrame:CGRectMake(SCREEN_SIZE_X - 54 - 10, SCREEN_SIZE_Y - 44 - 10, 54, 44)];
	[menuButton setImage:[UIImage imageNamed:@"ARMenuButton.png"] forState:UIControlStateNormal];
	[menuButton addTarget:self action:@selector(didTapMenuButton) forControlEvents:UIControlEventTouchUpInside];
	[menuButton setHidden:YES];
	[view addSubview:menuButton];
	[menuButton release];
	
	cancelButton = [[ARButton alloc] init];
	[cancelButton setFrame:CGRectMake(SCREEN_SIZE_X - 74 - 10, SCREEN_SIZE_Y - 50 - 10, 74, 44)];
	[cancelButton setTitle:NSLocalizedString(@"Cancel", @"button") forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(didTapCancelButton) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton setHidden:YES];
	[view addSubview:cancelButton];
	[cancelButton release];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[cameraViewController release];
	cameraViewController = nil;
	featureContainerView = nil;
	radarView = nil;
	overlayContainerView = nil;
	menuButton = nil;
	cancelButton = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[self cameraViewController] viewWillAppear:animated];

	// Use a display link to sync up with the screen, so that we don't update the screen more than necessary
	CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateWithDisplayLink:)];
	[link setFrameInterval:FRAME_INTERVAL];
	[self setDisplayLink:link];
	[link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	// Invalidate the screen by default
	[self setState:STATE_DIMENSION];
	[self setNeedsUpdate];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[self cameraViewController] viewDidAppear:animated];
	
	[self ensureStatusBarVisible];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[self cameraViewController] viewWillDisappear:animated];
	
	[[self spatialStateManager] stopUpdating];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[[self cameraViewController] viewDidDisappear:animated];
	
	// This invalidates the display link
	[self setDisplayLink:nil];
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
				[self startRefreshingOnDistanceResetLocation:NO];
			}
			[[self displayLink] setPaused:NO];
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

	// Cancel loading any assets before we start reloading them in the create... methods below
	[[self assetManagerIfAvailable] cancelLoadingAllAssets];
	
	[self createOverlayViews];
	[self createFeatureViews];
	
	[self startRefreshingOnTime];
	[self startRefreshingOnDistanceResetLocation:YES];
	
	// Remember this URL for when the app restarts
	// Note: don't remember file URLs, those change when the application's unique identifier on the device changes
	if (![[request url] isFileURL]) {
		[[NSUserDefaults standardUserDefaults] setObject:[[request url] absoluteString] forKey:DIMENSION_URL_DEFAULTS_KEY];
	}
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
	// Invalidate the screen, the display link will take care of actually updating the screen when needed
	[self setNeedsUpdate];
}

- (void)spatialStateManagerLocationDidUpdate:(ARSpatialStateManager *)manager {
	ARSpatialState *spatialState = [manager spatialState];
	if ([spatialState isLocationAvailable]) {
		[manager setEFToECEFSpaceOffset:[spatialState locationInECEFSpace]];
		
		// If we have a location fix, send a request for any pending URL
		if ([self pendingDimensionURL]) {
			[self startDimensionRequestWithURL:[self pendingDimensionURL] type:ARDimensionRequestTypeInit source:nil];
			[self setPendingDimensionURL:nil];
		}
		
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
		
		if (!([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"gamaray"])) {
			DebugLog(@"Ignoring invalid QR code: %@", [sym data]);
		} else {
			DebugLog(@"Loading dimension by QR code: %@", [sym data]);
			[self setState:STATE_DIMENSION];
			[self startDimensionRequestWithURL:url type:ARDimensionRequestTypeTimeRefresh source:nil];
		}
	}
	
	[barImage release];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case MENU_BUTTON_QR:
			[self setState:STATE_QR];
			break;
	}
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
	
	[self updateFeatureViews];
}

- (void)updateFeatureViews {
	[featureContainerView updateWithSpatialState:[spatialStateManager spatialState] usingRelativeAltitude:[dimension relativeAltitude]];
	[radarView updateWithSpatialState:[spatialStateManager spatialState] usingRelativeAltitude:[dimension relativeAltitude]];
}

- (void)setNeedsUpdate {
	needsUpdate = YES;
}

- (void)updateIfNeeded {
	if (needsUpdate) {
		needsUpdate = NO;
		
		[self updateFeatureViews];
	}
}

- (void)startDimensionRequestWithURL:(NSURL *)aURL type:(ARDimensionRequestType)type source:(NSString *)source {
	NSAssert(aURL, @"Expected non-nil URL.");
	
	// Cancel loading any assets
	[[self assetManagerIfAvailable] cancelLoadingAllAssets];
	
	// Make sure to kill any timer, since we don't want it firing when we're already refreshing
	[self stopRefreshingOnTime];
	[self stopRefreshingOnDistance];

	ARDimensionRequest *request = [[ARDimensionRequest alloc] initWithURL:aURL location:[[[self spatialStateManager] spatialState] location] type:type];
	[request setSource:source];
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
			[self setRefreshLocation:[[[self spatialStateManager] spatialState] location]];
		}
	}
}

- (void)stopRefreshingOnDistance {
	[self setRefreshingOnDistance:NO];
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

- (void)didTapMenuButton {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
	[actionSheet setDelegate:self];
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Scan QR code", @"actionsheet button")];
	//[actionSheet addButtonWithTitle:@"Enter URL"]
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"actionsheet button")];
	[actionSheet setCancelButtonIndex:MENU_BUTTON_CANCEL];
	[actionSheet showInView:[self view]];
	[actionSheet release];
}

- (void)didTapCancelButton {
	[self setState:STATE_DIMENSION];
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
	switch (state) {
		case STATE_DIMENSION:
			if (dimension) {
				[self startRefreshingOnTime];
				[self startRefreshingOnDistanceResetLocation:NO];
			}
			[[self spatialStateManager] startUpdating];
			[featureContainerView setHidden:NO];
			[overlayContainerView setHidden:NO];
			[radarView setHidden:NO];
			[menuButton setHidden:NO];
			[displayLink setPaused:NO];
			break;
		case STATE_QR:
			[cancelButton setHidden:NO];
			[self startScanning];
			break;
	}
}

- (void)didLeaveState:(int)state {
	switch (state) {
		case STATE_DIMENSION:
			[self stopRefreshingOnTime];
			[self stopRefreshingOnDistance];
			[spatialStateManager stopUpdating];
			[dimensionRequest cancel];
			[featureContainerView setHidden:YES];
			[overlayContainerView setHidden:YES];
			[radarView setHidden:YES];
			[menuButton setHidden:YES];
			[displayLink setPaused:YES];
			break;
		case STATE_QR:
			[cancelButton setHidden:YES];
			[self stopScanning];
			break;
	}
}

@end
