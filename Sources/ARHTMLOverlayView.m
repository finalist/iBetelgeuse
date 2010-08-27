//
//  ARHTMLOverlayView.m
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

#import "ARHTMLOverlayView.h"
#import "ARHTMLOverlay.h"
#import "ARButton.h"
#import <QuartzCore/QuartzCore.h>

#define HORIZONTAL_PADDING 5
#define VERTICAL_PADDING 5

@implementation ARHTMLOverlayView

@synthesize overlay;

#pragma mark NSObject

- (id)initWithOverlay:(AROverlay *)anOverlay {
	NSAssert([anOverlay isKindOfClass:[ARHTMLOverlay class]], @"Expected html overlay.");
	
	if (self = [super initWithOverlay:anOverlay]) {
		overlay = (ARHTMLOverlay *)[anOverlay retain];
		
		webView = [[UIWebView alloc] init];
		[webView setBackgroundColor:[UIColor whiteColor]];
		
		//Create a URL object.
		NSURL *url = [NSURL URLWithString:[overlay url]];
		
		//URL Requst Object
		NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
		
		//Load the request in the UIWebView.
		[webView loadRequest:requestObj];
		
		[self addSubview:webView];
		
		[self sizeToFit];
	}
	return self;
}

- (void)dealloc {
	[overlay release];
	[webView release];
	[super dealloc];
}

#pragma mark UIView

- (CGSize)sizeThatFits:(CGSize)size {
	size.width = [overlay width];
	size.height = [overlay height];
	return size;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect bounds = [self bounds];
	
	[webView setFrame:CGRectInset(bounds, HORIZONTAL_PADDING, VERTICAL_PADDING)];
}

@end
