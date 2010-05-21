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


@implementation ARImageOverlayView

@synthesize overlay;

#pragma mark NSObject

- (id)initWithImageOverlay:(ARImageOverlay *)anOverlay {
	if (self = [super init]) {
		overlay = [anOverlay retain];
		
		imageView = [[UIImageView alloc] init];
		[self addSubview:imageView];
		[imageView release];
	}
	return self;
}

- (void)dealloc {
	[overlay release];

	[super dealloc];
}

#pragma mark UIView

- (CGSize)sizeThatFits:(CGSize)size {
	return [imageView sizeThatFits:size];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
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
		}
		[imageView setImage:image];
		[self sizeToFit];
	}
}

@end
