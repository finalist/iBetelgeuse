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


@implementation ARTextOverlayView

#pragma mark NSObject

- (id)initWithOverlay:(AROverlay *)anOverlay {
	NSAssert([anOverlay isKindOfClass:[ARTextOverlay class]], @"Expected text overlay.");
	
	if (self = [super initWithOverlay:anOverlay]) {
		overlay = (ARTextOverlay *)[anOverlay retain];

		label = [[UILabel alloc] init];
		[label setFont:[UIFont systemFontOfSize:15]]; // TODO: Get rid of magic number
		[label setText:[overlay text]];
		[label setNumberOfLines:0];
		[self addSubview:label];
		[label release];
		
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
	if ([overlay width]) {
		return [label sizeThatFits:CGSizeMake([overlay width], HUGE_VAL)];
	}
	else {
		return [label sizeThatFits:size];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[label setFrame:[self bounds]];
}

@end
