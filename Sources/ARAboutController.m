//
//  ARAboutController.m
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

#import "ARAboutController.h"


@interface ARAboutController () <UIWebViewDelegate>

@end


@implementation ARAboutController

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		[self setTitle:NSLocalizedString(@"Info", @"about controller title")];
	}
	return self;
}

#pragma mark UIViewController

- (void)loadView {
	UIWebView *webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[webView setDelegate:self];
	
	NSURL *aboutURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"About" ofType:@"html"]];
	NSURLRequest *aboutRequest = [[NSURLRequest alloc] initWithURL:aboutURL];
	[webView loadRequest:aboutRequest];
	[aboutRequest release];
	
	[self setView:webView];
	[webView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request URL]];
	}
	else if (navigationType == UIWebViewNavigationTypeOther) {
		// This is our own request in loadView
		return YES;
	}
	return NO;
}

@end
