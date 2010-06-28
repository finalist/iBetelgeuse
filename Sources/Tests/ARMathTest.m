//
//  ARMathTest.m
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

#import "ARMathTest.h"


@implementation ARMathTest

- (void)testMin {
	GHAssertEquals(ARMin(1, 2), 1, nil);
	GHAssertEquals(ARMin(-1, -2), -2, nil);
}

- (void)testMax {
	GHAssertEquals(ARMax(1, 2), 2, nil);
	GHAssertEquals(ARMax(-1, -2), -1, nil);
}

- (void)testClamp {
	GHAssertEquals(ARClamp(1, 2, 4), 2, nil);
	GHAssertEquals(ARClamp(3, 2, 4), 3, nil);
	GHAssertEquals(ARClamp(5, 2, 4), 4, nil);
}

@end
