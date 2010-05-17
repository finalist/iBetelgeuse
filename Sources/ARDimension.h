//
//  ARDimension.h
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
#import <CoreLocation/CoreLocation.h>


@interface ARDimension : NSObject {
@private
	NSArray *features;
	NSArray *overlays;
	NSDictionary *locations;
	NSDictionary *assets;
	BOOL relativeAltitude;
	NSString *refreshURL;
	NSTimeInterval refreshTime;
	CLLocationDistance refreshDistance;
}

+ (void)startParsingWithXMLParser:(NSXMLParser *)parser element:(NSString *)element attributes:(NSDictionary *)attributes notifyTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo;

@property(nonatomic, readonly, copy) NSArray *features;
@property(nonatomic, readonly, copy) NSArray *overlays;
@property(nonatomic, readonly, copy) NSDictionary *locations;
@property(nonatomic, readonly, copy) NSDictionary *assets;
@property(nonatomic, readonly) BOOL relativeAltitude;
@property(nonatomic, readonly, copy) NSString *refreshURL;
@property(nonatomic, readonly) NSTimeInterval refreshTime;
@property(nonatomic, readonly) CLLocationDistance refreshDistance;

@end
