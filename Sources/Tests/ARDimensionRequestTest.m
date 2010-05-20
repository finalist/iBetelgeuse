//
//  ARDimensionRequestTest.m
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

#import "ARDimensionRequestTest.h"
#import "ARDimensionRequest.h"
#import "ARDimension.h"
#import "ARLocation.h"
#import "NSURLRequest+ARFormURLEncoding.h"
#import <CoreLocation/CoreLocation.h>
#import <GHUnit/GHMockNSURLConnection.h>


#define DIMENSION_URL @"http://www.foobar.com/?baz=1"
#define DIMENSION_LAT 10.0
#define DIMENSION_LON 20.0
#define DIMENSION_ALT 30.0
#define DIMENSION_SOURCE @"aSource"
#define DIMENSION_SCREEN_WIDTH 40.0
#define DIMENSION_SCREEN_HEIGHT 50.0


@interface ARDimensionRequestTest () <ARDimensionRequestDelegate>

- (void)performBareRequestWithType:(ARDimensionRequestType)type;

@end


@implementation ARDimensionRequestTest

#pragma mark GHTestCase

- (void)setUpClass {
	[super setUpClass];
	
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = DIMENSION_LAT;
	coordinate.longitude = DIMENSION_LON;
	
	CLLocation *coreLocation = [[CLLocation alloc] initWithCoordinate:coordinate altitude:DIMENSION_ALT horizontalAccuracy:0.0 verticalAccuracy:0.0 timestamp:nil];
	currentLocation = [[ARLocation alloc] initWithCLLocation:coreLocation];
	[coreLocation release];
}

- (void)tearDownClass {
	[currentLocation release];
	
	[super tearDownClass];
}

- (void)testInitializer {
	NSURL *url = [NSURL URLWithString:DIMENSION_URL];

	GHAssertThrows([[[ARDimensionRequest alloc] initWithURL:nil location:currentLocation type:ARDimensionRequestTypeDistanceRefresh] autorelease], @"Successful initialization despite nil URL.");
	GHAssertThrows([[[ARDimensionRequest alloc] initWithURL:url location:nil type:ARDimensionRequestTypeDistanceRefresh] autorelease], @"Successful initialization despite nil locatio.");

	// Test accessors after initializing with satisfiable arguments
	ARDimensionRequest *request = [[ARDimensionRequest alloc] initWithURL:url location:currentLocation type:ARDimensionRequestTypeDistanceRefresh];
	GHAssertEqualObjects([request url], url, nil);
	GHAssertEqualObjects([request location], currentLocation, nil);
	GHAssertEquals([request type], ARDimensionRequestTypeDistanceRefresh, nil);
	[request release];
}

- (void)testDidFinishComplete {
	// Necessary for GHAsyncTestCase
	[self prepare];
	
	// Build a complete dimension request
	ARDimensionRequest *request = [[ARDimensionRequest alloc] initWithURL:[NSURL URLWithString:DIMENSION_URL] location:currentLocation type:ARDimensionRequestTypeTimeRefresh];
	[request setDelegate:self];
	[request setSource:DIMENSION_SOURCE];
	[request setScreenSize:CGSizeMake(DIMENSION_SCREEN_WIDTH, DIMENSION_SCREEN_HEIGHT)];
	
	// Start the request and wait for it to finish
	// Note: various assertions will be done in dimensionRequest:didFailWithError: and such
	[request start];
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
	
	[request release];
}

- (void)testDidFail {
	[self performBareRequestWithType:ARDimensionRequestTypeInit];
}

- (void)testTypes {
	[self performBareRequestWithType:ARDimensionRequestTypeInit];
	GHAssertEqualObjects(event, @"init", nil);
	
	[self performBareRequestWithType:ARDimensionRequestTypeTimeRefresh];
	GHAssertEqualObjects(event, @"refreshOnTime", nil);
	
	[self performBareRequestWithType:ARDimensionRequestTypeDistanceRefresh];
	GHAssertEqualObjects(event, @"refreshOnDistance", nil);
	
	[self performBareRequestWithType:ARDimensionRequestTypeActionRefresh];
	GHAssertEqualObjects(event, @"refreshOnPress", nil);
}

// Note: this test isn't reliable with the GHMockNSURLConnection
//- (void)testCancel {
//	// Necessary for GHAsyncTestCase
//	[self prepare];
//	
//	// Build a dimension request
//	ARDimensionRequest *request = [[ARDimensionRequest alloc] initWithURL:[NSURL URLWithString:DIMENSION_URL] location:currentLocation type:ARDimensionRequestTypeInit];
//	[request setDelegate:self];
//	
//	// Start the request, cancel it and wait for it to timeout
//	[request start];
//	[request cancel];
//	[self waitForTimeout:0.5];
//	
//	// Start the request and wait for it to finish, just to make sure this does work
//	[request start];
//	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
//
//	[request release];
//}

#pragma mark ARDimensionRequestTest

- (void)performBareRequestWithType:(ARDimensionRequestType)type {
	// Necessary for GHAsyncTestCase
	[self prepare];
	
	// Build a dimension request
	ARDimensionRequest *request = [[ARDimensionRequest alloc] initWithURL:[NSURL URLWithString:DIMENSION_URL] location:currentLocation type:type];
	[request setDelegate:self];
	
	// Start the request and wait for it to finish
	// Note: various assertions will be done in dimensionRequest:didFailWithError: and such
	[request start];
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
	
	[request release];
}

#pragma mark ARDimensionRequestDelegate

- (void)dimensionRequest:(ARDimensionRequest *)request didFinishWithDimension:(ARDimension *)dimension {
	if ([self currentSelector] == @selector(testDidFinishComplete)) {
		GHAssertNotNil(dimension, nil);
		GHAssertEqualObjects([dimension refreshURL], [NSURL URLWithString:@"http://www.hoi.nl/"], nil);
	}
	else if ([self currentSelector] == @selector(testDidFail)) {
		GHFail(@"This request should've failed.");
	}
	
	// Notify that we're done
	[self notify:kGHUnitWaitStatusSuccess];
}

- (void)dimensionRequest:(ARDimensionRequest *)request didFailWithError:(NSError *)error {
	if ([self currentSelector] == @selector(testDidFinishComplete)) {
		GHFail(@"This request shouldn't've failed.");
	}
	else if ([self currentSelector] == @selector(testDidFail)) {
		GHAssertEqualObjects([error domain], ARDimensionRequestErrorDomain, nil);
		GHAssertEquals([error code], ARDimensionRequestErrorHTTP, nil);
		GHAssertEqualObjects([[error userInfo] objectForKey:ARDimensionRequestErrorHTTPStatusCodeKey], [NSNumber numberWithInteger:404], nil);
	}
	
	// Notify that we're done
	[self notify:kGHUnitWaitStatusSuccess];
}

- (NSURLConnection *)dimensionRequest:(ARDimensionRequest *)request connectionWithRequest:(NSURLRequest *)urlRequest delegate:(id)delegate {
	GHMockNSURLConnection *connection = [[GHMockNSURLConnection alloc] initWithRequest:urlRequest delegate:delegate];
	
	if ([self currentSelector] == @selector(testDidFinishComplete)) {
		// Check whether the HTTP method and URL are right
		GHAssertEqualStrings([urlRequest HTTPMethod], @"POST", nil);
		GHAssertEqualObjects([urlRequest URL], [NSURL URLWithString:DIMENSION_URL], nil);
		
		// Check the post 
		NSString *postString = [[NSString alloc] initWithData:[urlRequest HTTPBody] encoding:NSUTF8StringEncoding];
		NSDictionary *postData = [NSURLRequest ar_dictionaryWithFormURLEncodedString:postString];
		GHAssertEqualStrings([postData objectForKey:@"event"], @"refreshOnTime", nil);
		GHAssertEqualStrings([postData objectForKey:@"eventSrc"], DIMENSION_SOURCE, nil);
		GHAssertEquals([[postData objectForKey:@"lat"] doubleValue], (double)DIMENSION_LAT, nil);
		GHAssertEquals([[postData objectForKey:@"lon"] doubleValue], (double)DIMENSION_LON, nil);
		GHAssertEquals([[postData objectForKey:@"alt"] doubleValue], (double)DIMENSION_ALT, nil);
		GHAssertEquals([[postData objectForKey:@"width"] doubleValue], (double)DIMENSION_SCREEN_WIDTH, nil);
		GHAssertEquals([[postData objectForKey:@"height"] doubleValue], (double)DIMENSION_SCREEN_HEIGHT, nil);
		GHAssertNotNil([postData objectForKey:@"uid"], nil);
		GHAssertNotNil([postData objectForKey:@"time"], nil);
		[postString release];
		
		// Send an appropriate response
		NSData *responseData = [NSData dataWithContentsOfFile:TEST_RESOURCES_PATH @"/ARDimensionRequestTest.xml"];
		[connection receiveData:responseData statusCode:200 MIMEType:@"application/xml" afterDelay:0.1];
	}
	else if ([self currentSelector] == @selector(testDidFail)) {
		[connection receiveData:[NSData data] statusCode:404 MIMEType:@"text/html" afterDelay:0.1];
	}
	else if ([self currentSelector] == @selector(testTypes)) {
		// Check the post data
		NSString *postString = [[NSString alloc] initWithData:[urlRequest HTTPBody] encoding:NSUTF8StringEncoding];
		NSDictionary *postData = [NSURLRequest ar_dictionaryWithFormURLEncodedString:postString];
		
		[event release];
		event = [[postData objectForKey:@"event"] copy];
		[postString release];
		
		[connection failWithError:nil afterDelay:0.1];
	}
	else if ([self currentSelector] == @selector(testCancel)) {		
		[connection failWithError:nil afterDelay:0.25];
	}
	
	return [connection autorelease];
}

@end
