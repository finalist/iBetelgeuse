//
//  UIDevice+ARDevice.m
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

#import "UIDevice+ARDevice.h"
#import <sys/types.h>
#import <sys/sysctl.h>


static NSString *modelIdentifier = nil;


@implementation UIDevice (ARDevice)

- (NSString *)ar_modelIdentifier {
	if (modelIdentifier == nil) {
		size_t length = 0;
		sysctlbyname("hw.machine", NULL, &length, NULL, 0);
		
		char *machine = malloc(length);
		sysctlbyname("hw.machine", machine, &length, NULL, 0);
		
		modelIdentifier = [[NSString alloc] initWithCString:machine];
	}
	return modelIdentifier;
}

@end
