//
//  ARWGS84.h
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

#import <CoreLocation/CoreLocation.h>
#import "ARPoint3D.h"


extern const CLLocationDistance ARWGS84SemiMajorAxis;
extern const CLLocationDistance ARWGS84SemiMinorAxis;


/**
 * Convert a WGS84 coordinate to a ECEF coordinate.
 * @param latitude the WGS84 latitude.
 * @param longitude the WGS84 longitude.
 * @param altitude the WGS84 altitude.
 * @return the point in ECEF coordinate space.
 */
ARPoint3D ARWGS84GetECEF(CLLocationDegrees latitude, CLLocationDegrees longitude, CLLocationDistance altitude);
