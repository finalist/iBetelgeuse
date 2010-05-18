//
//  ARPoint3D.h
//  iBetelgeuse
//
//  Created by administrator on 5/18/10.
//  Copyright 2010 Finalist IT Group. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct {
	double x;
	double y;
	double z;
} ARPoint3D;


static inline ARPoint3D ARPoint3DCreate(double x, double y, double z) {
	ARPoint3D result;
	result.x = x;
	result.y = y;
	result.z = z;
	return result;
}

static inline bool ARPoint3DEquals(ARPoint3D a, ARPoint3D b) {
	return memcmp(&a, &b, sizeof(ARPoint3D)) == 0;
}
