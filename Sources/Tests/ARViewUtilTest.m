//
//  ARViewUtilTest.m
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

#import "ARViewUtilTest.h"
#import "ARViewUtil.h"


// Touch target size
#define TT 44.f


@interface ARViewUtilTest ()

- (void)assertRect:(CGRect)rect growsToTouchTargetRect:(CGRect)targetRect;
- (void)assertSize:(CGSize)size growsToTouchTargetSize:(CGSize)targetSize;

@end


@implementation ARViewUtilTest

#pragma mark GHTestCase

- (void)testMinimumTouchTargetSize {
	GHAssertEquals(ARMinimumTouchTargetSize, (CGFloat)TT, nil);
}

- (void)testRectGrowToTouchTarget {
	[self assertRect:CGRectMake(0, 0, 0, 0) growsToTouchTargetRect:CGRectMake(-TT / 2.f, -TT / 2.f, TT, TT)];
	[self assertRect:CGRectMake(0, 0, TT, TT) growsToTouchTargetRect:CGRectMake(0, 0, TT, TT)];
	[self assertRect:CGRectMake(-TT / 2.f, -TT / 2.f, TT, TT) growsToTouchTargetRect:CGRectMake(-TT / 2.f, -TT / 2.f, TT, TT)];
	[self assertRect:CGRectMake(-2.f * TT, -2.f * TT, 2.f * TT, 2.f * TT) growsToTouchTargetRect:CGRectMake(-2.f * TT, -2.f * TT, 2.f * TT, 2.f * TT)];
	[self assertRect:CGRectMake(0, 0, TT / 2.f, 2.f * TT) growsToTouchTargetRect:CGRectMake(-TT / 4.f, 0, TT, 2.f * TT)];
}

- (void)testSizeGrowToTouchTarget {
	[self assertSize:CGSizeMake(0, 0) growsToTouchTargetSize:CGSizeMake(TT, TT)];
	[self assertSize:CGSizeMake(TT, TT) growsToTouchTargetSize:CGSizeMake(TT, TT)];
	[self assertSize:CGSizeMake(2.f * TT, 2.f * TT) growsToTouchTargetSize:CGSizeMake(2.f * TT, 2.f * TT)];
	[self assertSize:CGSizeMake(TT / 2.f, 2.f * TT) growsToTouchTargetSize:CGSizeMake(TT, 2.f * TT)];
}

#pragma mark ARViewUtilTest

- (void)assertRect:(CGRect)rect growsToTouchTargetRect:(CGRect)targetRect {
	GHAssertTrue(CGRectEqualToRect(ARRectGrowToTouchTarget(rect), targetRect), nil);
}

- (void)assertSize:(CGSize)size growsToTouchTargetSize:(CGSize)targetSize {
	GHAssertTrue(CGSizeEqualToSize(ARSizeGrowToTouchTarget(size), targetSize), nil);
}

@end
