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


extern NSString *const ARAssetManagerErrorDomain;
extern const NSInteger ARAssetManagerErrorUnknown;
extern const NSInteger ARAssetManagerErrorHTTP;
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

- (void)assetManager:(ARAssetManager *)manager didLoadData:(NSData *)data forAsset:(ARAsset *)asset;
- (void)assetManager:(ARAssetManager *)manager didFailWithError:(NSError *)error forAsset:(ARAsset *)asset;

@optional

/**
 * Optional method that allows the delegate to inject a specific response to a request, which is useful for testing.
 *
 * @note This method may be called on a thread other than the main thread.
 */
- (NSData *)assetManager:(ARAssetManager *)manager respondToSynchronousRequest:(NSURLRequest *)request withResponse:(NSURLResponse **)response error:(NSError **)error;

@end
