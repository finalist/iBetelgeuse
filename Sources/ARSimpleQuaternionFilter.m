//
//  ARSimpleQuaternionFilter.m
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


#import "ARSimpleQuaternionFilter.h"
#import "ARArrayFilter.h"


@implementation ARSimpleQuaternionFilter

#pragma mark NSObject

- (id)initWithFactory:(ARFilterFactory *)aFactory {
	if (self = [super init]) {
		arrayFilter = [[ARArrayFilter alloc] initWithSize:4 factory:aFactory];
	}
	return self;
}

- (void)dealloc {
	[arrayFilter release];
	[super dealloc];
}

#pragma mark ARQuaternionFilter

- (ARQuaternion)filterWithInput:(ARQuaternion)input timestamp:(NSTimeInterval)aTimestamp {
	ARQuaternion output;
	[arrayFilter filterWithInputArray:(ARFilterValue *)&input outputArray:(ARFilterValue *)&output timestamp:aTimestamp];
	return output;
}

@end
