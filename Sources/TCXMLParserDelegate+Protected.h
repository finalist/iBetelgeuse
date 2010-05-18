//
//  TCXMLParserDelegate+Protected.h
//
//  Copyright 2009 Dennis Stevense. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "TCXMLParserDelegate.h"


@interface TCXMLParserDelegate ()

/**
 * Called when the parsing of an element starts. Can be overridden by subclasses. Default implementation does nothing.
 */
- (void)parsingDidStartWithElement:(NSString *)name attributes:(NSDictionary *)attributes;

/**
 * Called when the parser has found an element that does not contain any children. Can be overridden by subclasses. Default implementation does nothing.
 */
- (void)parsingDidFindSimpleElement:(NSString *)name attributes:(NSDictionary *)attributes content:(NSString *)content;

/**
 * Called when the parsing of an element is done. The return value is used as the first argument to the callback message. Can be overridden by subclasses. Default implementation returns self.
 */
- (id)parsingDidEndWithElementContent:(NSString *)content;

@end
