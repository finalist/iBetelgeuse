//
//  TCXMLParserDelegate+Protected.h
//  TravelCampKit
//
//  Created by Dennis Stevense on 09-12-2009.
//  Copyright 2009 Dennis Stevense. All rights reserved.
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
