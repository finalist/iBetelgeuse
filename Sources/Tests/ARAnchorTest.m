//
//  ARAnchorTest.m
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

#import "ARAnchorTest.h"
#import "ARAnchor.h"


@interface ARAnchorTest ()

- (void)assertAnchor:(ARAnchor)anchor isMadeWithValidXMLString:(NSString *)string;
- (void)assertDefaultAnchorIsMadeWithInvalidXMLString:(NSString *)string;

@end


@implementation ARAnchorTest

#pragma mark GHTestCase

- (void)testMakeWithValidXMLString {
	[self assertAnchor:ARAnchorMake(0.0, 0.0) isMadeWithValidXMLString:@"TL"];
	[self assertAnchor:ARAnchorMake(0.5, 0.0) isMadeWithValidXMLString:@"TC"];
	[self assertAnchor:ARAnchorMake(1.0, 0.0) isMadeWithValidXMLString:@"TR"];
	[self assertAnchor:ARAnchorMake(0.0, 0.5) isMadeWithValidXMLString:@"CL"];
	[self assertAnchor:ARAnchorMake(0.5, 0.5) isMadeWithValidXMLString:@"CC"];
	[self assertAnchor:ARAnchorMake(1.0, 0.5) isMadeWithValidXMLString:@"CR"];
	[self assertAnchor:ARAnchorMake(0.0, 1.0) isMadeWithValidXMLString:@"BL"];
	[self assertAnchor:ARAnchorMake(0.5, 1.0) isMadeWithValidXMLString:@"BC"];
	[self assertAnchor:ARAnchorMake(1.0, 1.0) isMadeWithValidXMLString:@"BR"];

	// Also try one with the valid return value set to NULL
	GHAssertEquals(ARAnchorMakeWithXMLString(@"BC", NULL), ARAnchorMake(0.5, 1.0), nil);
}

- (void)testMakeWithInvalidXMLString {
	[self assertDefaultAnchorIsMadeWithInvalidXMLString:nil];
	[self assertDefaultAnchorIsMadeWithInvalidXMLString:@""];
	[self assertDefaultAnchorIsMadeWithInvalidXMLString:@"T"];
	[self assertDefaultAnchorIsMadeWithInvalidXMLString:@"TX"];
	[self assertDefaultAnchorIsMadeWithInvalidXMLString:@"TLX"];
	[self assertDefaultAnchorIsMadeWithInvalidXMLString:@"XL"];
}
				   
#pragma mark ARAnchorTest

- (void)assertAnchor:(ARAnchor)anchor isMadeWithValidXMLString:(NSString *)string {
	BOOL valid = NO;
	GHAssertEquals(ARAnchorMakeWithXMLString(string, &valid), anchor, nil);
	GHAssertTrue(valid, nil);
}

- (void)assertDefaultAnchorIsMadeWithInvalidXMLString:(NSString *)string {
	BOOL valid = YES;
	GHAssertEquals(ARAnchorMakeWithXMLString(string, &valid), ARAnchorMake(0.5, 0.5), nil);
	GHAssertFalse(valid, nil);
}

@end
