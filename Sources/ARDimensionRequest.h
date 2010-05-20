//
//  ARDimensionRequest.h
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


extern NSString *const ARDimensionRequestErrorDomain;
extern const NSInteger ARDimensionRequestErrorHTTP;
extern NSString *const ARDimensionRequestErrorHTTPStatusCodeKey;


@class ARDimension, ARLocation;
@protocol ARDimensionRequestDelegate;


typedef enum {
	ARDimensionRequestTypeInit,
	ARDimensionRequestTypeTimeRefresh,
	ARDimensionRequestTypeDistanceRefresh,
	ARDimensionRequestTypeActionRefresh,
} ARDimensionRequestType;


/**
 * Class that can be used to asynchronously perform a Gamaray refresh request.
 */
@interface ARDimensionRequest : NSObject {
@private
	id <ARDimensionRequestDelegate> delegate;
	NSURL *url;
	ARLocation *location;
	ARDimensionRequestType type;
	NSString *source;
	CGSize screenSize;
	
	NSURLConnection *connection;
	NSURLResponse *response;
	NSMutableData *responseData;
	NSXMLParser *parser;
	ARDimension *dimension;
}

/**
 * Initializes the receiver with the given values.
 *
 * @param url The URL to which the request will be sent, must be non-nil.
 * @param location The current location of the device that will be sent to the server, must be non-nil.
 * @param type The type of request that will be sent to the server.
 *
 * @return The receiver.
 */
- (id)initWithURL:(NSURL *)url location:(ARLocation *)location type:(ARDimensionRequestType)type;

@property(nonatomic, assign) id <ARDimensionRequestDelegate> delegate;

/**
 * The URL to which the request will be sent, as provided to the initializer of this class.
 */
@property(nonatomic, readonly, retain) NSURL *url;

/**
 * The current location of the device, as provided to the initializer of this class.
 */
@property(nonatomic, readonly, retain) ARLocation *location;

/**
 * The type of refresh request, as provided to the initializer of this class.
 */
@property(nonatomic, readonly) ARDimensionRequestType type;

/**
 * The source of the request. Defaults to nil, in which case the string NULL will be sent to the server.
 */
@property(nonatomic, readwrite, retain) NSString *source;

/**
 * The available room for overlays. Defaults to CGSizeZero, in which case no screen size will be provided to the server.
 */
@property(nonatomic, readwrite) CGSize screenSize;

/**
 * Starts performing the request, if it hasn't already started. This method returns immediately. The delegate will be notified when the request is done.
 */
- (void)start;

/**
 * Cancels performing the request.
 */
- (void)cancel;

@end


/**
 * Protocol that should be implemented by users of the ARDimensionRequest class.
 */
@protocol ARDimensionRequestDelegate <NSObject>

- (void)dimensionRequest:(ARDimensionRequest *)request didFinishWithDimension:(ARDimension *)dimension;
- (void)dimensionRequest:(ARDimensionRequest *)request didFailWithError:(NSError *)error;

@optional

/**
 * Optional method that allows the delegate to inject a specific kind of NSURLConnection, which is useful for testing.
 *
 * @note This method may be called on a thread other than the main thread.
 *
 * @return An instance of NSURLConnection or a subclass that has been started.
 */
- (NSURLConnection *)dimensionRequest:(ARDimensionRequest *)request connectionWithRequest:(NSURLRequest *)urlRequest delegate:(id)delegate;

@end
