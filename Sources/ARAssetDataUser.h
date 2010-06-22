//
//  ARAssetDataUser.h
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


/**
 * Protocol that can be implemented by classes that have one or more asset identifiers and are in need of the assets' data.
 *
 * A user of a class can check whether it conforms to this protocol and use this protocol to ask it whether it needs any asset data.
 */
@protocol ARAssetDataUser <NSObject>

/**
 * Returns a set of asset identifiers for which this class wants to use asset data, but doesn't have the asset data yet.
 *
 * @return A set of strings.
 */
- (NSSet *)assetIdentifiersForNeededData;

/**
 * Tells the receiver to use the given asset data for the given asset identifier.
 *
 * @param data The asset data. May be nil, in which case any asset data currently being used for the given asset identifier is cleared.
 * @param identifier The asset identifier for which the data is given. May not be nil. Unknown asset identifiers are ignored.
 */
- (void)useData:(NSData *)data forAssetIdentifier:(NSString *)identifier;

/**
 * Tells the receiver that no data is available for the given asset identifier. It is always possible that data becomes available later.
 *
 * @param identifier The asset identifier for which data is unavailable. May not be nil. Unknown asset identifiers are ignored.
 */
- (void)setDataUnavailableForAssetIdentifier:(NSString *)identifier;

@end
