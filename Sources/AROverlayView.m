//
//  AROverlayView.m
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

#import "AROverlayView.h"
#import "ARImageOverlay.h"
#import "ARImageOverlayView.h"
#import "ARTextOverlay.h"
#import "ARTextOverlayView.h"


@implementation AROverlayView

@dynamic overlay; // Should be implemented by subclasses

#pragma mark AROverlayView

// Consult The Objective-C Programming Language > Allocating and Initializing Objects > Implementing an Initializer > Constraints and Conventions to see why we use id as a return type.
+ (id)viewForOverlay:(AROverlay *)overlay {
	NSAssert(overlay != nil, @"Expected non-nil overlay.");

	if ([overlay isKindOfClass:[ARImageOverlay class]]) {
		return [[[ARImageOverlayView alloc] initWithImageOverlay:(ARImageOverlay *)overlay] autorelease];
	}
	else if ([overlay isKindOfClass:[ARTextOverlay class]]) {
		return [[[ARTextOverlayView alloc] initWithTextOverlay:(ARTextOverlay *)overlay] autorelease];
	}
	else {
		DebugLog(@"Unknown overlay type: %@", [overlay class]);
		return nil;
	}
}

@end
