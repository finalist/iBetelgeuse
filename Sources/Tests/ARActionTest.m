//
//  ARActionTest.m
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

#import "ARActionTest.h"
#import "ARAction.h"


@implementation ARActionTest

#pragma mark GHTestCase

- (void)setUp {
}

- (void)testRefresh {
	ARAction *action = [[ARAction alloc] initWithString:@"refresh"];
	
	GHAssertEquals([action type], ARActionTypeRefresh, nil);
	GHAssertNil([action URL ], nil);
	
	[action release];
}

- (void)testRefreshAlternativeSyntax {
	ARAction *action = [[ARAction alloc] initWithString:@"refresh: http://www.example.com/"];
	
	GHAssertEquals([action type], ARActionTypeRefresh, nil);
	// GHAssertEqualObjects([action URL], [NSURL URLWithString:@"http://www.example.com/"], nil); // Don't care about URL.
	
	[action release];
}

- (void)testURL {
	ARAction *action = [[ARAction alloc] initWithString:@"webpage:http://www.example.com/"];
	
	GHAssertEquals([action type], ARActionTypeURL, nil);
	GHAssertEqualObjects([action URL], [NSURL URLWithString:@"http://www.example.com/"], nil);
	
	[action release];
}

- (void)testURLWhitespace {
	ARAction *action = [[ARAction alloc] initWithString:@"webpage: http://www.example.com/"];
	
	GHAssertEquals([action type], ARActionTypeURL, nil);
	GHAssertEqualObjects([action URL], [NSURL URLWithString:@"http://www.example.com/"], nil);
	
	[action release];
}

- (void)testURLIncomplete {
	ARAction *action = [[ARAction alloc] initWithString:@"webpage"];
	
	GHAssertNil(action, nil);
	
	[action release];
}

- (void)testDimension {
	ARAction *action = [[ARAction alloc] initWithString:@"dimension:http://www.example.com/"];
	
	GHAssertEquals([action type], ARActionTypeDimension, nil);
	GHAssertEqualObjects([action URL], [NSURL URLWithString:@"http://www.example.com/"], nil);
	
	[action release];
}

- (void)testDimensionWhitespace {
	ARAction *action = [[ARAction alloc] initWithString:@"dimension: http://www.example.com/"];
	
	GHAssertEquals([action type], ARActionTypeDimension, nil);
	GHAssertEqualObjects([action URL], [NSURL URLWithString:@"http://www.example.com/"], nil);
	
	[action release];
}

- (void)testDimensionIncomplete {
	ARAction *action = [[ARAction alloc] initWithString:@"dimension"];
	
	GHAssertNil(action, nil);
	
	[action release];
}

- (void)testInvalid {
	ARAction *action = [[ARAction alloc] initWithString:@"nonsense"];
	
	GHAssertNil(action, nil);
	
	[action release];
}

- (void)testInvalidEmpty {
	ARAction *action = [[ARAction alloc] initWithString:@""];
	
	GHAssertNil(action, nil);
	
	[action release];
}

@end
