//
//  ARAsset.h
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
 * Represents an asset in a Gamaray dimension.
 */
@interface ARAsset : NSObject {
@private
	NSString *identifier;
	NSString *format;
	NSURL *URL;
}

/**
 * Starts parsing an asset using the given XML parser and start element. Notifies the given target after the end element has been parsed, passing the result as the first argument which is either an instance of ARAsset or nil when parsing has failed.
 *
 * @param parser Must be non-nil.
 * @param element The name of the start element. Must be non-nil.
 * @param attributes The attributes of the start element.
 * @param target The target that will be notified when parsing is done. Optional.
 * @param selector The selector used when notifying the target. Required if a target was given.
 * @param userInfo Information that is passed as the second argument to the target. Optional.
 */
+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo;

/**
 * Initializes the receiver with the given values.
 *
 * @param url The URL of the asset. Must be non-nil.
 * @param format The format of the asset. May be nil.
 *
 * @return The receiver.
 */
- (id)initWithURL:(NSURL *)url format:(NSString *)format;

/**
 * The identifier of the receiver, which may be nil.
 */
@property(nonatomic, readonly, copy) NSString *identifier;

/**
 * The format of the receiver, which may be nil.
 */
@property(nonatomic, readonly, copy) NSString *format;

/**
 * The URL of the receiver, which may be nil initially but may not be set to a non-nil value.
 */
@property(nonatomic, readonly, copy) NSURL *URL;

@end
