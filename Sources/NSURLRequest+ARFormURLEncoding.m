//
//  NSURLRequest+ARFormURLEncoding.m
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

#import "NSURLRequest+ARFormURLEncoding.h"


@implementation NSURLRequest (ARFormURLEncoding)

+ (NSString *)ar_formURLEncodedStringWithDictionary:(NSDictionary *)dictionary {
	NSMutableString *result = [[NSMutableString alloc] init];
	
	for (NSString *key in [dictionary keyEnumerator]) {
		NSAssert([key isKindOfClass:[NSString class]], @"Expected string key.");
		[result appendString:[self ar_stringByURLEncodingString:key]];
		
		[result appendString:@"="];
		
		NSString *value = [dictionary objectForKey:key];
		NSAssert([value isKindOfClass:[NSString class]], @"Expected string value.");
		[result appendString:[self ar_stringByURLEncodingString:value]];
		
		[result appendString:@"&"];
	}
	
	return [result autorelease];
}

+ (NSDictionary *)ar_dictionaryWithFormURLEncodedString:(NSString *)string {
	NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
	
	NSScanner *scanner = [[NSScanner alloc] initWithString:string];
	NSString *buffer;
	while (![scanner isAtEnd]) {
		// Scan the key up to an equal sign
		if (![scanner scanUpToString:@"=" intoString:&buffer]) {
			buffer = @"";
		}
		
		// Eat the =
		[scanner scanString:@"=" intoString:NULL];
		
		NSAssert(buffer != nil, @"Expected buffer to be non-nil.");
		NSString *key = [self ar_stringByURLDecodingString:buffer];

		// Scan the value up to an ampersand
		if (![scanner scanUpToString:@"&" intoString:&buffer]) {
			buffer = @"";
		}
		
		// Eat the &
		[scanner scanString:@"&" intoString:NULL];

		NSAssert(buffer != nil, @"Expected buffer to be non-nil.");
		NSString *value = [self ar_stringByURLDecodingString:buffer];

		[result setObject:value forKey:key];
	}
	[scanner release];
	
	return [result autorelease];
}

+ (NSString *)ar_stringByURLEncodingString:(NSString *)string {
	if (string == nil) {
		return nil;
	}
	
	// We don't use stringByAddingPercentEscapesUsingEncoding: because we explicitly need to encode = and & characters as well
	CFStringRef result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR("=&"), kCFStringEncodingUTF8);
	return [(NSString *)result autorelease];
}

+ (NSString *)ar_stringByURLDecodingString:(NSString *)string {
	return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
