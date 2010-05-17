//
//  TCXMLParserDelegate.h
//  TravelCampKit
//
//  Created by Dennis Stevense on 08-12-2009.
//  Copyright 2009 Dennis Stevense. All rights reserved.
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
