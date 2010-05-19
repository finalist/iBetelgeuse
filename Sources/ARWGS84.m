//
//  ARWGS84.m
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
//  Calculations adapted from http://www.microem.ru/pages/u_blox/tech/dataconvert/GPS.G1-X-00006.pdf

#import "ARWGS84.h"


#define DEG_TO_RAD(deg) ((deg) / 180. * M_PI)
#define WGS84_A ARWGS84SemiMajorAxis
#define WGS84_B ARWGS84SemiMinorAxis


const CLLocationDistance ARWGS84SemiMajorAxis = 6378137.0;
const CLLocationDistance ARWGS84SemiMinorAxis = 6356752.31424518;


ARPoint3D ARWGS84GetECEF(CLLocationDegrees latitude, CLLocationDegrees longitude, CLLocationDistance altitude) {
	// Calculate the eccentricity
	double eccentricity = sqrt((WGS84_A * WGS84_A - WGS84_B * WGS84_B) / (WGS84_A * WGS84_A));
	
	// Calculate the radius of curvature
	CLLocationDistance radiusOfCurvature = WGS84_A / sqrt(1. - eccentricity * eccentricity * sin(DEG_TO_RAD(latitude)) * sin(DEG_TO_RAD(latitude)));

	ARPoint3D result;
	result.x = (radiusOfCurvature + altitude) * cos(DEG_TO_RAD(latitude)) * cos(DEG_TO_RAD(longitude));
	result.y = (radiusOfCurvature + altitude) * cos(DEG_TO_RAD(latitude)) * sin(DEG_TO_RAD(longitude));
	result.z = ((WGS84_B * WGS84_B) / (WGS84_A * WGS84_A) * radiusOfCurvature + altitude) * sin(DEG_TO_RAD(latitude));
	return result;
}
