//
//  ARAssetManagerTest.m
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

#import "ARAssetManagerTest.h"
#import "ARAssetManager.h"
#import "ARAsset.h"
#import <GHUnit/GHMockNSHTTPURLResponse.h>


#define GOOD_ASSET_URL @"http://www.example.org/good.jpg"
#define GOOD_ASSET_FORMAT @"JPEG"
#define GOOD_ASSET_DATA "hoi123"

#define BAD_ASSET_URL @"http://www.example.org/bad.png"
#define BAD_ASSET_FORMAT @"PNG"


@interface ARAssetManagerTest () <ARAssetManagerDelegate>

- (void)notifySuccessIfNeeded;

@end


@implementation ARAssetManagerTest

#pragma mark NSObject

- (void)dealloc {
	[goodAsset release];
	[goodAsset2 release];
	[badAsset release];
	
	[super dealloc];
}

#pragma mark GHTestCase

- (void)setUpClass {
	[super setUpClass];
	
	[goodAsset release];
	goodAsset = [[ARAsset alloc] initWithURL:[NSURL URLWithString:GOOD_ASSET_URL] format:GOOD_ASSET_FORMAT];
	
	[goodAsset2 release];
	goodAsset2 = [[ARAsset alloc] initWithURL:[NSURL URLWithString:GOOD_ASSET_URL] format:GOOD_ASSET_FORMAT];
	
	[badAsset release];
	badAsset = [[ARAsset alloc] initWithURL:[NSURL URLWithString:BAD_ASSET_URL] format:BAD_ASSET_FORMAT];
}

- (void)setUp {
	[super setUp];
	
	pendingDidLoads = 0;
	pendingDidFails = 0;
}

- (void)testLoadingOneAsset {
	ARAssetManager *manager = [[ARAssetManager alloc] init];
	[manager setDelegate:self];

	[self prepare];
	[manager startLoadingAsset:goodAsset];
	pendingDidLoads = 1;
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:0.5];
	
	[manager release];
}

- (void)testLoadingOneFailingAsset {
	ARAssetManager *manager = [[ARAssetManager alloc] init];
	[manager setDelegate:self];

	[self prepare];
	[manager startLoadingAsset:badAsset];
	pendingDidFails = 1;
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:0.5];
	
	[manager release];
}

- (void)testLoadingOneAssetTwice {
	ARAssetManager *manager = [[ARAssetManager alloc] init];
	[manager setDelegate:self];
	
	[self prepare];
	[manager startLoadingAsset:goodAsset];
	[manager startLoadingAsset:goodAsset];
	pendingDidLoads = 2;
	[self waitForTimeout:0.5];
	
	[manager release];
}

- (void)testCancelLoadingOneAsset {
	ARAssetManager *manager = [[ARAssetManager alloc] init];
	[manager setDelegate:self];
	
	[self prepare];
	[manager startLoadingAsset:goodAsset];
	pendingDidLoads = 1;
	usleep(10000);
	[manager cancelLoadingAsset:goodAsset];
	[self waitForTimeout:0.5];
	
	[manager release];
}

- (void)testLoadingTwoAssets {
	ARAssetManager *manager = [[ARAssetManager alloc] init];
	[manager setDelegate:self];
	
	[self prepare];
	[manager startLoadingAsset:goodAsset];
	[manager startLoadingAsset:badAsset];
	pendingDidLoads = 1;
	pendingDidFails = 1;
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:0.5];
	
	[manager release];
}

- (void)testLoadingTwoAssetsWithSameURL {
	ARAssetManager *manager = [[ARAssetManager alloc] init];
	[manager setDelegate:self];
	
	[self prepare];
	[manager startLoadingAsset:goodAsset];
	[manager startLoadingAsset:goodAsset2];
	pendingDidLoads = 2;
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:0.5];
	
	[manager release];
}

- (void)testCancelLoadingAllAssets {
	ARAssetManager *manager = [[ARAssetManager alloc] init];
	[manager setDelegate:self];
	
	[self prepare];
	[manager startLoadingAsset:goodAsset];
	[manager startLoadingAsset:badAsset];
	pendingDidLoads = 1;
	pendingDidFails = 1;
	usleep(10000);
	[manager cancelLoadingAllAssets];
	[self waitForTimeout:0.5];
	
	[manager release];
}

#pragma mark ARAssetManagerTest

- (void)assetManager:(ARAssetManager *)manager didLoadData:(NSData *)data forAsset:(ARAsset *)asset {
	if (asset == goodAsset || asset == goodAsset2) {
		GHAssertEqualObjects(data, [NSData dataWithBytesNoCopy:GOOD_ASSET_DATA length:strlen(GOOD_ASSET_DATA) freeWhenDone:NO], nil);
		
		pendingDidLoads--;
		[self notifySuccessIfNeeded];
	}
}

- (void)assetManager:(ARAssetManager *)manager didFailWithError:(NSError *)error forAsset:(ARAsset *)asset {
	if (asset == badAsset) {
		GHAssertEqualObjects([error domain], ARAssetManagerErrorDomain, nil);
		GHAssertEqualObjects([[error userInfo] objectForKey:ARAssetManagerErrorHTTPStatusCodeKey], [NSNumber numberWithInteger:404], nil);
		
		pendingDidFails--;
		[self notifySuccessIfNeeded];
	}
}

- (NSData *)assetManager:(ARAssetManager *)manager respondToSynchronousRequest:(NSURLRequest *)request withResponse:(NSURLResponse **)response error:(NSError **)error {
	usleep(100000);
	
	if ([[request URL] isEqual:[NSURL URLWithString:GOOD_ASSET_URL]]) {
		if (response != NULL) {
			*response = [[[GHMockNSHTTPURLResponse alloc] initWithStatusCode:200 headers:nil] autorelease];
		}
		
		if (error != NULL) {
			*error = nil;
		}

		return [NSData dataWithBytesNoCopy:GOOD_ASSET_DATA length:strlen(GOOD_ASSET_DATA) freeWhenDone:NO];
	}
	else {
		if (response != NULL) {
			*response = [[[GHMockNSHTTPURLResponse alloc] initWithStatusCode:404 headers:nil] autorelease];
		}
		
		if (error != NULL) {
			*error = nil;
		}
		
		return [NSData data];
	}
}

#pragma mark ARAssetManagerTest

- (void)notifySuccessIfNeeded {
	if (pendingDidLoads == 0 && pendingDidFails == 0) {
		[self notify:kGHUnitWaitStatusSuccess];
	}	
}

@end
