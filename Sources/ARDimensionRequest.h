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


@class ARDimension, ARSpatialState;
@protocol ARDimensionRequestDelegate;


/**
 * The domain of errors returned by the ARDimensionRequest class.
 */
extern NSString *const ARDimensionRequestErrorDomain;

/**
 * Error code that indicates the dimension request failed due to an HTTP error.
 */
extern const NSInteger ARDimensionRequestErrorHTTP;

/**
 * Key into the userInfo dictionary of an error that indicates the returned HTTP status code. Only used together with the ARDimensionRequestErrorHTTP error code.
 */
extern NSString *const ARDimensionRequestErrorHTTPStatusCodeKey;

/**
 * Error code that indicates the dimension request was not able to find a dimension in the response. (Not even an invalid dimension.)
 */
extern const NSInteger ARDimensionRequestErrorDocument;


/**
 * Used to indicate the type of the dimension request.
 */
typedef enum {
	/**
	 * Indicates an initial request. Could be the first time a dimension is loaded or a manual refresh.
	 */
	ARDimensionRequestTypeInit,
	
	/**
	 * Indicates this is dimension request due to the elapsed refreshTime since the last request.
	 */
	ARDimensionRequestTypeTimeRefresh,
	
	/**
	 * Indicates this is dimension request due to the travelled refreshDistance from the location of the last request.
	 */
	ARDimensionRequestTypeDistanceRefresh,
	
	/**
	 * Indicates this is dimension request due to a user action, such as tapping on an item.
	 */
	ARDimensionRequestTypeActionRefresh,
} ARDimensionRequestType;


/**
 * Class that can be used to asynchronously perform a Gamaray refresh request.
 */
@interface ARDimensionRequest : NSObject {
@private
	id <ARDimensionRequestDelegate> delegate;
	
	// Parameters of the request
	NSURL *url;
	ARSpatialState *spatialState;
	ARDimensionRequestType type;
	NSString *source;
	CGSize screenSize;
	
	// Request and parsing facilities
	NSURLConnection *connection;
	NSURLResponse *response;
	NSMutableData *responseData;
	NSXMLParser *parser;
	BOOL didAbortParsing;
	
	ARDimension *dimension;
}

/**
 * Initializes the receiver with the given values.
 *
 * @param url The URL to which the request will be sent, must be non-nil. Supported URL schemes are http, gamaray and file.
 * @param spatialState The current spatial state of the device that will be sent to the server, must be non-nil.
 * @param type The type of request that will be sent to the server.
 *
 * @return The receiver.
 */
- (id)initWithURL:(NSURL *)url spatialState:(ARSpatialState *)spatialState type:(ARDimensionRequestType)type;

/**
 * The delegate of the receiver that will be notified when the request finishes or fails.
 */
@property(nonatomic, assign) id <ARDimensionRequestDelegate> delegate;

/**
 * The URL to which the request will be sent, as provided to the initializer of this class.
 */
@property(nonatomic, readonly, retain) NSURL *url;

/**
 * The current spatial state of the device, as provided to the initializer of this class.
 */
@property(nonatomic, readonly, retain) ARSpatialState *spatialState;

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

/**
 * Called when the dimension request has finished and successfully loaded a dimension.
 *
 * @param request The sender of the message.
 * @param dimension The dimension that has been loaded.
 */
- (void)dimensionRequest:(ARDimensionRequest *)request didFinishWithDimension:(ARDimension *)dimension;

/**
 * Called when the dimension request has failed to load a dimension.
 *
 * @param request The sender of the message.
 * @param error The error that occured. May be nil or any kind of error, including an ARDimensionRequest error, NSXMLParser error or NSURL error.
 */
- (void)dimensionRequest:(ARDimensionRequest *)request didFailWithError:(NSError *)error;

@optional

/**
 * Optional method that allows the delegate to inject a specific kind of NSURLConnection, which is useful for testing.
 *
 * @param request The sender of the message.
 * @param urlRequest The request that should be used to create the NSURLConnection.
 * @param delegate The delegate that should be given to the NSURLConnection.
 *
 * @note This method may be called on a thread other than the main thread.
 *
 * @return An instance of NSURLConnection or a subclass that has been started.
 */
- (NSURLConnection *)dimensionRequest:(ARDimensionRequest *)request connectionWithRequest:(NSURLRequest *)urlRequest delegate:(id)delegate;

@end
