//
//  ARFormURLEncodingTest.m
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

#import "ARFormURLEncodingTest.h"
#import "NSURLRequest+ARFormURLEncoding.h"


@interface ARFormURLEncodingTest ()

- (void)assertBijectionWithDictionary:(NSDictionary *)dictionary;

@end


@implementation ARFormURLEncodingTest

#pragma mark GHTestCase

- (void)testFormURLEncodingAndDecoding {
	GHAssertEqualObjects([NSURLRequest ar_formURLEncodedStringWithDictionary:nil], @"", nil);
	GHAssertEqualObjects([NSURLRequest ar_dictionaryWithFormURLEncodedString:nil], [NSDictionary dictionary], nil);
	
	[self assertBijectionWithDictionary:[NSDictionary dictionary]];
	[self assertBijectionWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"aValue", @"aKey", @"baz +&=", @"=&+ foo", nil]];
	[self assertBijectionWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"b", nil]];
	[self assertBijectionWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"a", @"", nil]];
	[self assertBijectionWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"a", @"b", @"", @"d", @"e", @"", @"g", @"h", nil]];
}

- (void)testURLEncoding {
	GHAssertNil([NSURLRequest ar_stringByURLEncodingString:nil], nil);
	GHAssertEqualObjects([NSURLRequest ar_stringByURLEncodingString:@""], @"", nil);
	GHAssertEqualObjects([NSURLRequest ar_stringByURLEncodingString:@"aValue"], @"aValue", nil);
	GHAssertEqualObjects([NSURLRequest ar_stringByURLEncodingString:@"baz +&="], @"baz%20+%26%3D", nil);
	GHAssertEqualObjects([NSURLRequest ar_stringByURLEncodingString:@"=&+ foo"], @"%3D%26+%20foo", nil);
}

- (void)testURLDecoding {
	GHAssertNil([NSURLRequest ar_stringByURLDecodingString:nil], nil);
	GHAssertEqualObjects([NSURLRequest ar_stringByURLDecodingString:@""], @"", nil);
	GHAssertEqualObjects([NSURLRequest ar_stringByURLDecodingString:@"aValue"], @"aValue", nil);
	GHAssertEqualObjects([NSURLRequest ar_stringByURLDecodingString:@"baz%20+%26%3D"], @"baz +&=", nil);
	GHAssertEqualObjects([NSURLRequest ar_stringByURLDecodingString:@"%3D%26+%20foo"], @"=&+ foo", nil);
}

#pragma mark ARFormURLEncodingTest

- (void)assertBijectionWithDictionary:(NSDictionary *)dictionary {
	GHAssertEqualObjects([NSURLRequest ar_dictionaryWithFormURLEncodedString:[NSURLRequest ar_formURLEncodedStringWithDictionary:dictionary]], dictionary, nil);
}

@end
