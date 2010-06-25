//
//  ARCyclicBufferTest.m
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

#import "ARCyclicBufferTest.h"
#import "ARCyclicBuffer.h"



@implementation ARCyclicBufferTest

#pragma mark GHTestCase

- (void)testElementCount {
	ARCyclicBuffer *buffer = [[ARCyclicBuffer alloc] initWithElementSize:sizeof(int) maxElementCount:3];
	int value = 123;
	
	GHAssertEquals(0, [buffer elementCount], nil);
	[buffer pushElement:&value];
	GHAssertEquals(1, [buffer elementCount], nil);
	[buffer pushElement:&value];
	GHAssertEquals(2, [buffer elementCount], nil);
	[buffer pushElement:&value];
	GHAssertEquals(3, [buffer elementCount], nil);
	[buffer pushElement:&value];
	GHAssertEquals(3, [buffer elementCount], nil);
	
	[buffer release];
}

- (void)testOldestElement {
	ARCyclicBuffer *buffer = [[ARCyclicBuffer alloc] initWithElementSize:sizeof(int) maxElementCount:3];
	int value1 = 1.2;
	int value2 = -3.4;
	int value3 = 5.6;
	int value4 = -7.8;
	
	[buffer pushElement:&value1];
	GHAssertEquals(value1, *(int*)[buffer oldestElement], nil);
	[buffer pushElement:&value2];
	GHAssertEquals(value1, *(int*)[buffer oldestElement], nil);
	[buffer pushElement:&value3];
	GHAssertEquals(value1, *(int*)[buffer oldestElement], nil);
	[buffer pushElement:&value4];
	GHAssertEquals(value2, *(int*)[buffer oldestElement], nil);
	
	[buffer release];
}

- (void)testPushElement {
	/*
	 This assumes that the newly inserted index increase modulus maxElementCount,
	 this is not guaranteed by the class documentation, but does hold in our implementation.
	 */
	
	ARCyclicBuffer *buffer = [[ARCyclicBuffer alloc] initWithElementSize:sizeof(int) maxElementCount:3];
	int value1 = 1.2;
	int value2 = -3.4;
	int value3 = 5.6;
	int value4 = -7.8;
	
	[buffer pushElement:&value1];
	GHAssertEquals(value1, ((int*)[buffer elements])[0], nil);
	[buffer pushElement:&value2];
	GHAssertEquals(value2, ((int*)[buffer elements])[1], nil);
	[buffer pushElement:&value3];
	GHAssertEquals(value3, ((int*)[buffer elements])[2], nil);
	[buffer pushElement:&value4];
	GHAssertEquals(value4, ((int*)[buffer elements])[0], nil);
	
	[buffer release];
}

@end
