//
//  AROverlay.h
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
#import "ARAnchor.h"


@class ARAction;


/**
 * Abstract class that represents an overlay in a Gamaray dimension.
 */
@interface AROverlay : NSObject {
@private
	NSString *identifier;
	CGPoint origin;
	ARAnchor anchor;
	ARAction *action;
}

/**
 * Starts parsing an overlay using the given XML parser and start element. Notifies the given target after the end element has been parsed, passing the result as the first argument which is either an instance of the receiver or nil when parsing has failed.
 *
 * @param parser Must be non-nil.
 * @param element The name of the start element. Must be non-nil.
 * @param attributes The attributes of the start element.
 * @param target The target that will be notified when parsing is done. Optional.
 * @param selector The selector used when notifying the target. Required if a target was given.
 * @param userInfo Information that is passed as the second argument to the target. Optional.
 */
+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo;

@property(nonatomic, readonly, copy) NSString *identifier;
@property(nonatomic, readonly) CGPoint origin;
@property(nonatomic, readonly) CGPoint anchor;
@property(nonatomic, readonly, retain) ARAction *action;

@end
