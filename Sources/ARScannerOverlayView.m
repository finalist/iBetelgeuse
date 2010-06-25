//
//  ARScannerOverlayView.m
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

#import "ARScannerOverlayView.h"


#define BOX_MARGIN_FACTOR .25
#define BOX_LINE_WIDTH 2.0
#define BOX_OPACITY 0.5


@implementation ARScannerOverlayView

#pragma mark NSObject

- (id)initWithFrame:(CGRect)aFrame {
	if (self = [super initWithFrame:aFrame]) {
		[self setBackgroundColor:[UIColor clearColor]];
		[self setUserInteractionEnabled:NO];
		[self setContentMode:UIViewContentModeCenter];
	}
	return self;
}

#pragma mark UIView

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGRect bounds = [self bounds];

	// Inset the red rectangle from our bounds
	CGFloat boxMargin = ARMin(bounds.size.width, bounds.size.height) * BOX_MARGIN_FACTOR;
	CGRect box = CGRectInset(bounds, boxMargin, boxMargin);
	
	// Turn it into a centered square
	if (box.size.width > box.size.height) {
		box.origin.x += (box.size.width - box.size.height) / 2.0;
		box.size.width = box.size.height;
	}
	else {
		box.origin.y += (box.size.height - box.size.width) / 2.0;
		box.size.height = box.size.width;
	}
	
	CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, BOX_OPACITY);
	CGContextSetLineWidth(ctx, BOX_LINE_WIDTH);
	CGContextStrokeRect(ctx, box);
}

@end
