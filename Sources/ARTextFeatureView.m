//
//  ARTextFeatureView.m
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

#import "ARTextFeatureView.h"
#import "ARTextFeature.h"
#import <QuartzCore/QuartzCore.h>


#define HORIZONTAL_PADDING 5
#define VERTICAL_PADDING 2
#define CORNER_RADIUS 4
#define FONT_SIZE 14


@implementation ARTextFeatureView

@synthesize feature;

#pragma mark NSObject

- (id)initWithFeature:(ARFeature *)aFeature {
	NSAssert([aFeature isKindOfClass:[ARTextFeature class]], @"Expected text feature.");
	
	if (self = [super initWithFeature:aFeature]) {
		feature = (ARTextFeature *)[aFeature retain];
		
		label = [[UILabel alloc] init];
		[label setText:[feature text]];
		[label setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
		[label setTextColor:[UIColor blackColor]];
		[label setNumberOfLines:0];
		[label setBackgroundColor:nil];
		[label setOpaque:NO];
		[self addSubview:label]; 
		[label release];
		
		// Note: this is YES by default on UILabels, but that causes off-screen rendering making everything very slow. Since we are sizing the label to fit, we can safely set it to NO to considerably improve rendering speed.
		[label setClipsToBounds:NO];
		
		[self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
		[[self layer] setCornerRadius:CORNER_RADIUS];
		
		[self sizeToFit];
	}
	return self;
}

- (void)dealloc {
	[feature release];
	[super dealloc];
}

#pragma mark UIView

- (CGSize)sizeThatFits:(CGSize)size {
	size = [label sizeThatFits:size];
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
