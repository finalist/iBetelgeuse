//
//  ARDoubleExponentialFilter.h
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


#import "ARFilter.h"


@interface ARDoubleExponentialFilter : ARFilter {
@private
	double alpha;
	double gamma;
	
	ARFilterValue lastOutput;
	ARFilterValue trend;
	int sampleCount;
}

- (id)initWithAlpha:(double)alpha;
- (id)initWithAlpha:(double)alpha gamma:(double)gamma;

@property(nonatomic, readwrite) double alpha;
@property(nonatomic, readwrite) double gamma;

@end