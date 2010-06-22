//
//  ARImageOverlayView.m
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

#import "ARImageOverlayView.h"
#import "ARImageOverlay.h"


#define ACTIVITY_INDICATOR_SIZE 12.0


@interface ARImageOverlayView ()

- (void)showActivityIndicatorView;
- (void)showImageViewWithImage:(UIImage *)image;

@end


@implementation ARImageOverlayView

@synthesize overlay;

#pragma mark NSObject

- (id)initWithOverlay:(AROverlay *)anOverlay {
	NSAssert([anOverlay isKindOfClass:[ARImageOverlay class]], @"Expected image overlay.");
	
	if (self = [super initWithOverlay:anOverlay]) {
		overlay = (ARImageOverlay *)[anOverlay retain];
		
		[self showActivityIndicatorView];
	}
	return self;
}

- (void)dealloc {
	[overlay release];

	[super dealloc];
}

#pragma mark UIView

- (CGSize)sizeThatFits:(CGSize)size {
	if (activityIndicatorView) {
		return CGSizeMake(ACTIVITY_INDICATOR_SIZE, ACTIVITY_INDICATOR_SIZE);
	}
	else if (imageView) {
		return [[imageView image] size];
	}
	else {
		return size;
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[activityIndicatorView setFrame:[self bounds]];
	[imageView setFrame:[self bounds]];
}

#pragma mark ARAssetDataUser

- (NSSet *)assetIdentifiersForNeededData {
	if ([overlay assetIdentifier] && [imageView image] == nil) {
		return [NSSet setWithObject:[overlay assetIdentifier]];
	}
	else {
		return [NSSet set];
	}
}

- (void)useData:(NSData *)data forAssetIdentifier:(NSString *)identifier {
	NSAssert(identifier != nil, @"Expected non-nil identifier.");
	
	if ([identifier isEqual:[overlay assetIdentifier]]) {
		UIImage *image = [UIImage imageWithData:data]; // imageWithData: returns nil when data is nil
		if (data != nil && image == nil) {
			DebugLog(@"Image could not be initialized from asset data");
			[self showImageViewWithImage:[UIImage imageNamed:@"AssetFailed.png"]];
		}
		else {
			[self showImageViewWithImage:image];
		}
	}
}

- (void)setDataUnavailableForAssetIdentifier:(NSString *)identifier {
	NSAssert(identifier != nil, @"Expected non-nil identifier.");
	
	if ([identifier isEqual:[overlay assetIdentifier]]) {
		[self showImageViewWithImage:[UIImage imageNamed:@"AssetFailed.png"]];
	}
}

#pragma mark ARImageOverlayView

- (void)showActivityIndicatorView {
	if (imageView != nil) {
		[imageView removeFromSuperview];
		imageView = nil;
	}
	
	if (activityIndicatorView == nil) {
		activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self addSubview:activityIndicatorView];
		[activityIndicatorView release];
	}
	
	[activityIndicatorView startAnimating];
	[self sizeToFit];
}

- (void)showImageViewWithImage:(UIImage *)image {
	if (activityIndicatorView != nil) {
		[activityIndicatorView removeFromSuperview];
		activityIndicatorView = nil;
	}
	
	if (imageView == nil) {
		imageView = [[UIImageView alloc] init];
		[self addSubview:imageView];
		[imageView release];
	}
	
	[imageView setImage:image];
	[self sizeToFit];
}

@end
