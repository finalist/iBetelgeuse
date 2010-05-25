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


@implementation ARTextFeatureView

@synthesize feature;

#pragma mark NSObject

- (void)dealloc {
	[feature release];
	[super dealloc];
}

#pragma mark UIView

- (CGSize)sizeThatFits:(CGSize)size {
	return [label sizeThatFits:size];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[label setFrame:[self bounds]];
}

#pragma mark ARTextFeatureView

- (id)initWithFeature:(ARFeature *)aFeature {
	NSAssert([aFeature isKindOfClass:[ARTextFeature class]], @"Expected text feature.");
	
	if (self = [super init])
	{
		feature = (ARTextFeature *)[aFeature retain];
		
		[[self layer] setAnchorPoint:[feature anchor]];
		
		label = [[UILabel alloc] init];
		[label setFont:[UIFont systemFontOfSize:15]]; // TODO: Get rid of magic number
		[label setText:[feature text]];
		[label setNumberOfLines:0];
		[self addSubview:label]; 
		[label release];
		
		[self sizeToFit];
	}
	return self;
}

@end
