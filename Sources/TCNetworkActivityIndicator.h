//
//  TCNetworkActivityIndicator.h
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

#import <UIKit/UIKit.h>


/**
 * Class that can be used to manage the network activity indicator.
 */
@interface TCNetworkActivityIndicator : NSObject {
@private
	NSMutableSet *retainingTokens;
}

/**
 * Returns the singleton instance of this class.
 */
+ (TCNetworkActivityIndicator *)sharedIndicator;

/**
 * Ensures the network activity indicator remains visible until the given token has released it. Retaining the indicator more than once with the same token has no effect.
 *
 * @param token The token, which must be non-nil.
 */
- (void)retainWithToken:(id)token;

/**
 * Releases the network activity indicator with the given token, hiding it if no other tokens are retaining it. Release the indicator with a token that is not retaining it has no effect.
 *
 * @param token The token, which must be non-nil.
 */
- (void)releaseWithToken:(id)token;

@end
