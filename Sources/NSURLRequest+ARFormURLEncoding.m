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


@interface NSURLRequest (_ARFormURLEncoding)

+ (NSString *)_ar_stringByURLEncodingString:(NSString *)string;
+ (NSString *)_ar_stringByURLDecodingString:(NSString *)string;

@end


@implementation NSURLRequest (ARFormURLEncoding)

+ (NSString *)ar_formURLEncodedStringWithDictionary:(NSDictionary *)dictionary {
	NSMutableString *result = [[NSMutableString alloc] init];
	
	for (NSString *key in [dictionary keyEnumerator]) {
		[result appendString:[self _ar_stringByURLEncodingString:key]];
		[result appendString:@"="];
		[result appendString:[self _ar_stringByURLEncodingString:[[dictionary objectForKey:key] description]]];
		[result appendString:@"&"];
	}
	
	return [result autorelease];
}

+ (NSDictionary *)ar_dictionaryWithFormURLEncodedString:(NSString *)string {
	NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
	
	NSScanner *scanner = [[NSScanner alloc] initWithString:string];
	NSString *buffer;
	while ([scanner scanUpToString:@"=" intoString:&buffer]) {
		NSString *key = [self _ar_stringByURLDecodingString:buffer];
		
		[scanner scanString:@"=" intoString:NULL];
		if ([scanner scanUpToString:@"&" intoString:&buffer]) {
			NSString *value = [self _ar_stringByURLDecodingString:buffer];
			[result setObject:value forKey:key];
			
			[scanner scanString:@"&" intoString:NULL];
		}
	}
	[scanner release];
	
	return [result autorelease];
}

+ (NSString *)_ar_stringByURLEncodingString:(NSString *)string {
	// We don't use stringByAddingPercentEscapesUsingEncoding: because we explicitly need to additionally encode = and & characters
	CFStringRef result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR("=&"), kCFStringEncodingUTF8);
	return [(NSString *)result autorelease];
}

+ (NSString *)_ar_stringByURLDecodingString:(NSString *)string {
	return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
