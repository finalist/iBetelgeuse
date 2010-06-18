//
//  ARMainController.h
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

#import "ARDimensionRequest.h"
#import "ARAssetManager.h"
#import "ARSpatialStateManager.h"
#import <zbar/ZBarReaderController.h>


@class ARFeatureContainerView, AROverlayContainerView, ARRadarView, ARScannerOverlayView, ARLocation;


@interface ARMainController : UIViewController <ARDimensionRequestDelegate, ARAssetManagerDelegate, ARSpatialStateManagerDelegate, UIActionSheetDelegate> {
@private
	NSURL *pendingDimensionURL;
	ARDimension *dimension;
	UIImagePickerController *cameraViewController;
	ARFeatureContainerView *featureContainerView; // Non-retained instance variable
	AROverlayContainerView *overlayContainerView; // Non-retained instance variable
	ARRadarView *radarView; // Non-retained instance variable
	ARScannerOverlayView *scannerOverlayView; // Non-retained instance variable
	UIImageView *locationWarningView; // Non-retained instance variable
	UIImageView *orientationWarningView; // Non-retained instance variable
	UIButton *menuButton; // Non-retained instance variable
	UIButton *cancelButton; // Non-retained instance variable
	
	CADisplayLink *displayLink;
	BOOL needsUpdate;
	
	ARDimensionRequest *dimensionRequest;
	ARAssetManager *assetManager;
	ARSpatialStateManager *spatialStateManager;
	NSTimer *refreshTimer;
	NSDate *refreshTime;
	ZBarImageScanner *scanner;
	NSTimer *scanTimer;
	BOOL refreshingOnDistance;
	ARLocation *refreshLocation;
	int currentState;
		
	struct {
		signed char about;
		signed char refresh;
		signed char qr;
		signed char cancel;
	} menuButtonIndices;
}

/**
 * Initialize the receiver with the given URL. If a URL is given, the controller will start loading the dimension at that URL as soon as it becomes visible.
 *
 * @param url A URL to start loading a dimension from. May be nil.
 *
 * @return The receiver.
 */
- (id)initWithURL:(NSURL *)url;

@end
