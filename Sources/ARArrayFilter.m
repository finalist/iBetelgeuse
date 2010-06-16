//
//  ARArrayFilter.m
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


#import "ARArrayFilter.h"
#import "ARFilter.h"


@implementation ARArrayFilter

#pragma mark NSObject

- (id)initWithSize:(int)aSize factory:(ARFilterFactory *)aFactory {
	if (self = [super init]) {
		size = aSize;
		filters = (ARFilter **)malloc(size*sizeof(ARFilter *));
		
		for (int i = 0; i < size; i++) {
			filters[i] = [aFactory newFilter];
		}
	}
	return self;
}

- (void)dealloc {
	for (int i = 0; i < size; i++) {
		[filters[i] release];
	}
	
	free(filters);
	
	[super dealloc];
}

#pragma mark ARArrayFilter

- (void)filterWithInputArray:(ARFilterValue *)input outputArray:(ARFilterValue *)output timestamp:(NSTimeInterval)aTimestamp {
	for (int i = 0; i < size; i++) {
		output[i] = [filters[i] filterWithInput:input[i] timestamp:aTimestamp];
	}
}

@end
