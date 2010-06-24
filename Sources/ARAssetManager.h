//
//  ARAssetManager.h
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
// 

#import <Foundation/Foundation.h>


@class ARAsset;
@protocol ARAssetManagerDelegate;


/**
 * The domain of errors returned by the ARAssetManager class.
 */
extern NSString *const ARAssetManagerErrorDomain;

/**
 * Error code that indicates the asset failed to load due to an unknown error.
 */
extern const NSInteger ARAssetManagerErrorUnknown;

/**
 * Error code that indicates the dimension request failed due to an HTTP error.
 */
extern const NSInteger ARAssetManagerErrorHTTP;

/**
 * Key into the userInfo dictionary of an error that indicates the returned HTTP status code. Only used together with the ARAssetManagerErrorHTTP error code.
 */
extern NSString *const ARAssetManagerErrorHTTPStatusCodeKey;


/**
 * Manages the asynchronous loading and possibly caching of assets. Assets are instances of ARAsset. The result of loading an asset is an NSData object.
 */
@interface ARAssetManager : NSObject {
@private
	id <ARAssetManagerDelegate> delegate; // Non-retained instance variable
	NSOperationQueue *operationQueue;
	NSMutableDictionary *operations;
}

/**
 * The delegate of the receiver that will be notified when loading an asset finishes or fails.
 */
@property(nonatomic, assign) id <ARAssetManagerDelegate> delegate;

/**
 * Starts loading the given asset. When finished, the delegate will be notified either with the loaded data or with an error. More than one asset may be loading at any given time, and loading an asset that is already being loaded has no effect.
 *
 * @param asset The asset to start loading, may not be nil.
 */
- (void)startLoadingAsset:(ARAsset *)asset;

/**
 * Cancels loading the given asset. The delegate will not be notified about this asset anymore.
 *
 * @param asset The asset to cancel loading, may not be nil.
 */
- (void)cancelLoadingAsset:(ARAsset *)asset;

/**
 * Cancels loading all assets. The delegate will not be notified anymore unless startLoadingAsset: is called again.
 */
- (void)cancelLoadingAllAssets;

@end


/**
 * Protocol that should be implemented by users of the ARAssetManager class.
 */
@protocol ARAssetManagerDelegate <NSObject>

/**
 * Called when the asset manager has finished and successfully loaded asset data.
 *
 * @param manager The sender of the message.
 * @param data The asset data that has been loaded.
 * @param asset The asset for which data has been loaded.
 */
- (void)assetManager:(ARAssetManager *)manager didLoadData:(NSData *)data forAsset:(ARAsset *)asset;

/**
 * Called when the asset manager has failed to load asset data.
 *
 * @param manager The sender of the message.
 * @param error The error that occured. May be nil or any kind of error.
 * @param asset The asset for which data has failed to load.
 */
- (void)assetManager:(ARAssetManager *)manager didFailWithError:(NSError *)error forAsset:(ARAsset *)asset;

@optional

/**
 * Optional method that allows the delegate to inject a specific response to a request, which is useful for testing.
 *
 * @param manager The sender of the message.
 * @param request The request that needs a response.
 * @param response This memory location should hold the response to the request, or nil. Should not be a NULL-reference.
 * @param error This memory location should hold the error that occured, or nil. Should not be a NULL-reference.
 *
 * @note This method may be called on a thread other than the main thread.
 */
- (NSData *)assetManager:(ARAssetManager *)manager respondToSynchronousRequest:(NSURLRequest *)request withResponse:(NSURLResponse **)response error:(NSError **)error;

@end
