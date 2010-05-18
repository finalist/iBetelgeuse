//
//  TCXMLParserDelegate.h
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

#import <Foundation/Foundation.h>


/**
 * Utility class that can be used when parsing a hierarchy of classes using an NSXMLParser.
 */
@interface TCXMLParserDelegate : NSObject {
@private
	id parentParserDelegate;
	id target;
	SEL selector;
	id userInfo;
	
	NSString *startElement;
	NSUInteger elementDepth;
	NSDictionary *elementAttributes;
	BOOL simpleElement;
	NSMutableString *stringBuffer;
}

/**
 * This method should be called from parser:didStartElement:namespaceURI:qualifiedName:attributes: when the respective element and its children should be parsed by this parser. The given target will be notified when parsing of the element has completed.
 */
- (void)startWithXMLParser:(NSXMLParser *)parser element:(NSString *)name attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo;

@end


#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_6

@interface TCXMLParserDelegate () <NSXMLParserDelegate>

@end

#endif
