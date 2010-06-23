//
//  ARTextOverlayView.m
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

#import "ARTextOverlayView.h"
#import "ARTextOverlay.h"
#import <QuartzCore/QuartzCore.h>


#define HORIZONTAL_PADDING 5
#define VERTICAL_PADDING 2
#define FONT_SIZE 14


@implementation ARTextOverlayView

@synthesize overlay;

#pragma mark NSObject

- (id)initWithOverlay:(AROverlay *)anOverlay {
	NSAssert([anOverlay isKindOfClass:[ARTextOverlay class]], @"Expected text overlay.");
	
	if (self = [super initWithOverlay:anOverlay]) {
		overlay = (ARTextOverlay *)[anOverlay retain];

		label = [[UILabel alloc] init];
		[label setText:[overlay text]];
		[label setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
		[label setTextColor:[UIColor whiteColor]];
		[label setNumberOfLines:0];
		[label setBackgroundColor:nil];
		[label setOpaque:NO];
		[self addSubview:label];
		[label release];
		
		// Note: this is YES by default on UILabels, but that causes off-screen rendering making everything very slow. Since we are sizing the label to fit, we can safely set it to NO to considerably improve rendering speed.
		[label setClipsToBounds:NO];
		
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		
		[self sizeToFit];
	}
	return self;
}

- (void)dealloc {
	[overlay release];
	[super dealloc];
}

#pragma mark UIView

- (CGSize)sizeThatFits:(CGSize)size {
	if ([overlay width] != ARTextOverlayWidthUndefined) {
		CGFloat targetWidth = [overlay width] - 2.0 * HORIZONTAL_PADDING;
		size = [label sizeThatFits:CGSizeMake(targetWidth, HUGE_VAL)];
		size.width = targetWidth;
	}
	else {
		size = [label sizeThatFits:size];
	}
	size.width += 2.0 * HORIZONTAL_PADDING;
	size.height += 2.0 * VERTICAL_PADDING;
	return size;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect bounds = [self bounds];
	
	[label setFrame:CGRectInset(bounds, HORIZONTAL_PADDING, VERTICAL_PADDING)];
}

@end
