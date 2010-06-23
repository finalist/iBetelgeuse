//
//  ARAnchor.c
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

#import "ARAnchor.h"


ARAnchor ARAnchorMakeWithXMLString(NSString *string, BOOL *resultValid) {
	BOOL valid = [string length] == 2;
	CGPoint result;
	
	// If still valid, parse the horizontal component
	if (valid) {
		switch ([string characterAtIndex:1]) {
			case 'L':
			case 'l':
				result.x = 0.0;
				break;
				
			case 'C':
			case 'c':
				result.x = 0.5;
				break;
				
			case 'R':
			case 'r':
				result.x = 1.0;
				break;
				
			default:
				valid = NO;
				break;
		}
	}
	
	// If still valid, parse the vertical component
	if (valid) {
		switch ([string characterAtIndex:0]) {
			case 'T':
			case 't':
				result.y = 0.0;
				break;
				
			case 'C':
			case 'c':
				result.y = 0.5;
				break;
				
			case 'B':
			case 'b':
				result.y = 1.0;
				break;
				
			default:
				valid = NO;
				break;
		}
	}
	
	if (resultValid != NULL) {
		*resultValid = valid;
	}
	
	if (valid) {
		return result;
	}
	else {
		return ARAnchorMake(0.5, 0.5);
	}
}
