//
//  ARButton.m
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

#import "ARButton.h"
#import <QuartzCore/QuartzCore.h>


#define CORNER_RADIUS 4
#define FONT_SIZE 14


@implementation ARButton

#pragma mark NSObject

- (id)init {
	if (self = [self initWithFrame:CGRectZero]) {
		[self sizeToFit];
	}
	return self;
}

// Note: apparently this is the designated initializer when calling buttonWithType:UIButtonTypeCustom
- (id)initWithFrame:(CGRect)aFrame {
	if (self = [super initWithFrame:aFrame]) {
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
		[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
		[self setShowsTouchWhenHighlighted:YES];
		
		[[self layer] setCornerRadius:CORNER_RADIUS];
	}
	return self;
}

#pragma mark UIView

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(44, 44);
}

@end
