//
//  NSURLRequest+ARFormURLEncoding.h
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

#import <Foundation/Foundation.h>


/**
 * Category on NSURLRequest that adds methods for encoding and decoding dictionaries as application/x-www-form-urlencoded strings. See http://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.1 for details about this encoding.
 */
@interface NSURLRequest (ARFormURLEncoding)

/**
 * Encodes the given keys and values into an application/x-www-form-urlencoded encoded string.
 *
 * @param dictionary A dictionary. May be nil, in which case an empty string is returned.
 *
 * @return An application/x-www-form-urlencoded encoded string.
 */
+ (NSString *)ar_formURLEncodedStringWithDictionary:(NSDictionary *)dictionary;

/**
 * Decodes the given application/x-www-form-urlencoded encoded string into keys and values.
 *
 * @param string A application/x-www-form-urlencoded encoded string. May be nil, in which case an empty dictionary is returned.
 *
 * @return A dictionary.
 */
+ (NSDictionary *)ar_dictionaryWithFormURLEncodedString:(NSString *)string;

/**
 * Encodes the given string into a URL encoded string by adding percent escapes. Unlike stringByAddingPercentEscapesUsingEncoding: this method also escapes the = and & characters.
 *
 * @param string A string. May be nil, in which case nil is returned.
 *
 * @return An application/x-www-form-urlencoded encoded string, or nil if the input was nil.
 */
+ (NSString *)ar_stringByURLEncodingString:(NSString *)string;

/**
 * Decodes the given URL encoded string by removing percent escapes.
 *
 * @param string A string. May be nil, in which case nil is returned.
 *
 * @return A string, or nil if the input was nil.
 */
+ (NSString *)ar_stringByURLDecodingString:(NSString *)string;

@end
