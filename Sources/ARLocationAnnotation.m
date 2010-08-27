//
//  ARLocationAnnotation.m
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

#import "ARLocationAnnotation.h"
#import <MapKit/MapKit.h>


@implementation ARLocationAnnotation

@synthesize location;

- (ARLocationAnnotation *)initWithLocation:(ARLocation *) aLocation {
	self = [super init];
	location = aLocation;
	return self;
}

- (CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = location.latitude;
	theCoordinate.longitude = location.longitude;
	return theCoordinate; 
}

- (void)dealloc {
	[location release];
	
    [super dealloc];
}


@end
