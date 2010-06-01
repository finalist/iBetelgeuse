//
//  ARAssetManager.m
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

#import "ARAssetManager.h"
#import "ARAsset.h"

#if TARGET_OS_IPHONE
	#import "TCNetworkActivityIndicator.h"
#endif


NSString *const ARAssetManagerErrorDomain = @"ARAssetManagerErrorDomain";
const NSInteger ARAssetManagerErrorUnknown = 0;
const NSInteger ARAssetManagerErrorHTTP = 1;
NSString *const ARAssetManagerErrorHTTPStatusCodeKey = @"statusCode";


@interface ARAssetManagerOperationKey : NSObject <NSCopying> {
@private
	NSURL *URL;
}

- (id)initWithAsset:(ARAsset *)asset;

@property(nonatomic, readonly) NSURL *URL;

@end


@protocol ARAssetManagerOperationDelegate;


@interface ARAssetManagerOperation : NSOperation {
@private
	id <ARAssetManagerOperationDelegate> delegate; // Non-retained instance variable
	NSThread *delegateThread;
	ARAsset *asset;
}

- (id)initWithAsset:(ARAsset *)asset;

@property(nonatomic, assign) id <ARAssetManagerOperationDelegate> delegate;
@property(nonatomic, readonly) ARAsset *asset;

@end


@protocol ARAssetManagerOperationDelegate <NSObject>

- (void)assetManagerOperation:(ARAssetManagerOperation *)operation didFinishWithData:(NSData *)data;
- (void)assetManagerOperation:(ARAssetManagerOperation *)operation didFinishWithError:(NSError *)error;

/**
 * @note This method may be called on a thread other than the main thread.
 */
- (NSData *)assetManagerOperation:(ARAssetManagerOperation *)operation respondToSynchronousRequest:(NSURLRequest *)request withResponse:(NSURLResponse **)response error:(NSError **)error;

@end


@interface ARAssetManager () <ARAssetManagerOperationDelegate>

@property(nonatomic, readonly) NSOperationQueue *operationQueue;
@property(nonatomic, readonly) NSMutableDictionary *operations;
@property(nonatomic, readonly) NSMutableDictionary *operationsIfAvailable;

- (void)unregisterOperationForAsset:(ARAsset *)asset;
- (void)unregisterOperationForKey:(ARAssetManagerOperationKey *)key;

- (void)hideNetworkActivityIndicatorIfNeeded;

@end


@implementation ARAssetManager

@synthesize delegate;

#pragma mark NSObject

- (void)dealloc {
	[self cancelLoadingAllAssets];
	
	[operationQueue release];
	[operations release];
	
	[super dealloc];
}

#pragma mark ARAssetManagerOperationDelegate

- (void)assetManagerOperation:(ARAssetManagerOperation *)operation didFinishWithData:(NSData *)data {
	[self unregisterOperationForAsset:[operation asset]];
	
	DebugLog(@"Finished loading asset with identifier: %@", [[operation asset] identifier]);
	
	[delegate assetManager:self didLoadData:data forAsset:[operation asset]];
	
	[self hideNetworkActivityIndicatorIfNeeded];
}

- (void)assetManagerOperation:(ARAssetManagerOperation *)operation didFinishWithError:(NSError *)error {
	[self unregisterOperationForAsset:[operation asset]];
	
	DebugLog(@"Failed loading asset with identifier: %@\n%@", [[operation asset] identifier], error);
	
	[delegate assetManager:self didFailWithError:error forAsset:[operation asset]];
	
	[self hideNetworkActivityIndicatorIfNeeded];
}

- (NSData *)assetManagerOperation:(ARAssetManagerOperation *)operation respondToSynchronousRequest:(NSURLRequest *)request withResponse:(NSURLResponse **)response error:(NSError **)error {
	if ([delegate respondsToSelector:@selector(assetManager:respondToSynchronousRequest:withResponse:error:)]) {
		return [delegate assetManager:self respondToSynchronousRequest:request withResponse:response error:error];
	}
	else {
		return [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
	}
}

#pragma mark ARAssetManager

- (NSOperationQueue *)operationQueue {
	// Lazily create an operation queue if necessary
	if (operationQueue == nil) {
		operationQueue = [[NSOperationQueue alloc] init];
	}
	return operationQueue;
}

- (NSMutableDictionary *)operations {
	// Lazily create a mutable dictionary if necessary
	if (operations == nil) {
		operations = [[NSMutableDictionary alloc] init];
	}
	return operations;
}

- (NSMutableDictionary *)operationsIfAvailable {
	// This is an accessor that doesn't lazily create a new dictionary
	return operations;
}

- (void)startLoadingAsset:(ARAsset *)asset {
#if TARGET_OS_IPHONE
	[[TCNetworkActivityIndicator sharedIndicator] retainWithToken:self];
#endif
	
	ARAssetManagerOperationKey *key = [[ARAssetManagerOperationKey alloc] initWithAsset:asset];
	if ([[self operationsIfAvailable] objectForKey:key]) {
		DebugLog(@"Received request to start loading asset that is already loading: %@", [asset identifier]);
	}
	else {
		ARAssetManagerOperation *operation = [[ARAssetManagerOperation alloc] initWithAsset:asset];
		[operation setDelegate:self];
		[[self operationQueue] addOperation:operation];
		[[self operations] setObject:operation forKey:key];
		[operation release];
		
		DebugLog(@"Starting loading asset with identifier: %@", [asset identifier]);
	}
	[key release];
}

- (void)cancelLoadingAsset:(ARAsset *)asset {
	ARAssetManagerOperationKey *key = [[ARAssetManagerOperationKey alloc] initWithAsset:asset];
	[[[self operationsIfAvailable] objectForKey:key] cancel];
	[self unregisterOperationForKey:key];
	[key release];
	
	DebugLog(@"Cancelled loading asset with identifier: %@", [asset identifier]);
	
	[self hideNetworkActivityIndicatorIfNeeded];
}

- (void)cancelLoadingAllAssets {
	[[self operationsIfAvailable] removeAllObjects];
	[operationQueue cancelAllOperations];
	
	DebugLog(@"Cancelling loading all assets");
	
	[self hideNetworkActivityIndicatorIfNeeded];
}

- (void)unregisterOperationForAsset:(ARAsset *)asset {
	ARAssetManagerOperationKey *key = [[ARAssetManagerOperationKey alloc] initWithAsset:asset];
	[self unregisterOperationForKey:key];
	[key release];
}

- (void)unregisterOperationForKey:(ARAssetManagerOperationKey *)key {
	[[self operationsIfAvailable] removeObjectForKey:key];
}

- (void)hideNetworkActivityIndicatorIfNeeded {
#if TARGET_OS_IPHONE
	if ([[self operationsIfAvailable] count] == 0) {
		[[TCNetworkActivityIndicator sharedIndicator] releaseWithToken:self];
	}
#endif
}

@end


@implementation ARAssetManagerOperationKey

@synthesize URL;

#pragma mark NSObject

- (id)initWithAsset:(ARAsset *)asset {
	if (self = [super init]) {
		URL = [[asset URL] retain];
	}
	return self;
}

- (void)dealloc {
	[URL release];
	
	[super dealloc];
}

- (BOOL)isEqual:(id)other {
	if (self == other) {
		return YES;
	}
	else if ([other isKindOfClass:[ARAssetManagerOperationKey class]]) {
		ARAssetManagerOperationKey *otherKey = (ARAssetManagerOperationKey *)other;
		return URL == otherKey->URL || [URL isEqual:otherKey->URL];
	}
	else {
		return NO;
	}
}

- (NSUInteger)hash {
	return [URL hash];
}

- (NSString *)description {
	return [URL absoluteString];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	// Since this is a fully immutable object, just retain ourselves
	return [self retain];
}

@end


@implementation ARAssetManagerOperation

@synthesize delegate, asset;

#pragma mark NSObject

- (id)initWithAsset:(ARAsset *)anAsset {
	if (self = [super init]) {
		delegateThread = [[NSThread currentThread] retain];
		asset = [anAsset retain];
	}
	return self;
}

- (void)dealloc {
	[delegateThread release];
	[asset release];
	
	[super dealloc];
}

#pragma mark NSOperation

- (void)main {
	// Since this method is executed in a new thread, create an autorelease pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// We also musn't allow exceptions to escape this method
	@try {
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[asset URL]];

		NSURLResponse *response;
		NSError *error;
		NSData *responseData = [delegate assetManagerOperation:self respondToSynchronousRequest:request withResponse:&response error:&error];

		if (![self isCancelled]) {
			// Check the HTTP status code if possible
			// Note: NSURLConnection should take care of all 2xx and 3xx responses automatically
			if ([response isKindOfClass:[NSHTTPURLResponse class]] && [(NSHTTPURLResponse *)response statusCode] != 200) {
				NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

				NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"Received HTTP %@.", @"asset manager error descriptoin"), [NSHTTPURLResponse localizedStringForStatusCode:statusCode]];
				NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, [NSNumber numberWithInteger:statusCode], ARAssetManagerErrorHTTPStatusCodeKey, nil];
				NSError *error = [NSError errorWithDomain:ARAssetManagerErrorDomain code:ARAssetManagerErrorHTTP userInfo:errorInfo];
				[self performSelector:@selector(notifyDidFinishWithError:) onThread:delegateThread withObject:error waitUntilDone:NO];
			}
			else if (responseData) {
				[self performSelector:@selector(notifyDidFinishWithData:) onThread:delegateThread withObject:responseData waitUntilDone:NO];
			}
			else {
				[self performSelector:@selector(notifyDidFinishWithError:) onThread:delegateThread withObject:error waitUntilDone:NO];
			}
		}
		
		[request release];	 
	}
	@catch(id exception) {
		NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"Caught exception %@.", @"asset manager error description"), [exception name]];
		NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, [exception reason], NSLocalizedFailureReasonErrorKey, nil];
		NSError *error = [NSError errorWithDomain:ARAssetManagerErrorDomain code:ARAssetManagerErrorUnknown userInfo:errorInfo];
		[self performSelector:@selector(notifyDidFinishWithError:) onThread:delegateThread withObject:error waitUntilDone:NO];
	}
	@finally {
		// Always release the autorelease pool
		[pool release];
	}
}

#pragma mark ARAssetManagerOperation

- (void)notifyDidFinishWithData:(NSData *)data {
	// Don't call the delegate when we've been cancelled
	if (![self isCancelled]) {
		[delegate assetManagerOperation:self didFinishWithData:data];
	}	
}

- (void)notifyDidFinishWithError:(NSError *)error {
	// Don't call the delegate when we've been cancelled
	if (![self isCancelled]) {
		[delegate assetManagerOperation:self didFinishWithError:error];
	}
}

@end
