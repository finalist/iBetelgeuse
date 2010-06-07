//
//  ARPoint3DFilter.m
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


#import "ARPoint3DFilter.h"
#import "ARFilter.h"


@implementation ARPoint3DFilter

#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		for (int i = 0; i < 3; i++) {
			filters[i] = [self newCoordinateFilter];
		}
	}
	return self;
}

- (void)dealloc {
	for (int i = 0; i < 3; i++) {
		[filters[i] release];
	}
	
	[super dealloc];
}

#pragma mark ARPoint3DFilter

- (ARFilter *)newCoordinateFilter {
	return nil;
}

- (ARPoint3D)filterWithInput:(ARPoint3D)input {
	ARPoint3D output;
	for (int i = 0; i < 3; i++) {
		ARPoint3DSetCoordinate(&output, i, [filters[i] filterWithInput:ARPoint3DGetCoordinate(input, i)]);
	}
	return output;
}

@end
