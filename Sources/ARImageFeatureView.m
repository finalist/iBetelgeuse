//
//  ARImageFeatureView.m
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

#import "ARImageFeatureView.h"
#import "ARImageFeature.h"
#import <QuartzCore/QuartzCore.h>


#define PADDING 4
#define CORNER_RADIUS 4
#define ACTIVITY_INDICATOR_SIZE 2.0


@interface ARImageFeatureView ()

/**
 * Display the activity indicator placeholder, to be used when the image data is
 * not yet loaded.
 */
- (void)showActivityIndicatorView;

/**
 * Remove a possible placeholder and display an image.
 * @param image the image.
 */
- (void)showImageViewWithImage:(UIImage *)image;

@end


@implementation ARImageFeatureView

@synthesize feature;

#pragma mark NSObject

- (id)initWithFeature:(ARFeature *)aFeature {
	NSAssert([aFeature isKindOfClass:[ARImageFeature class]], @"Expected image feature.");
	
	if (self = [super initWithFeature:aFeature]) {
		feature = (ARImageFeature *)[aFeature retain];
		
		[self showActivityIndicatorView];
	}
	return self;
}

- (void)dealloc {
	[feature release];
	
	[super dealloc];
}

#pragma mark UIView

- (CGSize)sizeThatFits:(CGSize)size {
	if (activityIndicatorView) {
		return CGSizeMake(ACTIVITY_INDICATOR_SIZE, ACTIVITY_INDICATOR_SIZE);
	}
	else if (imageView) {
		size = [[imageView image] size];
		size.width += 2.0 * PADDING;
		size.height += 2.0 * PADDING;
		return size;
	}
	else {
		return size;
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect bounds = [self bounds];

	[activityIndicatorView setFrame:bounds];
	[imageView setFrame:CGRectInset(bounds, PADDING, PADDING)];
}

#pragma mark ARAssetDataUser

- (NSSet *)assetIdentifiersForNeededData {
	if ([feature assetIdentifier] && [imageView image] == nil) {
		return [NSSet setWithObject:[feature assetIdentifier]];
	}
	else {
		return [NSSet set];
	}
}

- (void)useData:(NSData *)data forAssetIdentifier:(NSString *)identifier {
	NSAssert(identifier != nil, @"Expected non-nil identifier.");
	
	if ([identifier isEqual:[feature assetIdentifier]]) {
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
	
	if ([identifier isEqual:[feature assetIdentifier]]) {
		[self showImageViewWithImage:[UIImage imageNamed:@"AssetFailed.png"]];
	}
}

#pragma mark ARImageFeatureView

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
	
	[self setBackgroundColor:nil];
	[[self layer] setCornerRadius:0.0];
	
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
	
	[self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
	[[self layer] setCornerRadius:CORNER_RADIUS];
	
	[self sizeToFit];
}

@end
