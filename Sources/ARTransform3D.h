//
//  ARTransform3D.h
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

#import <QuartzCore/QuartzCore.h>
#import "ARPoint3D.h"


typedef CATransform3D ARTransform3D;


/**
 * Constructs a transformation matrix given its x, y, and z axes and
 * translation:
 * 
 * TODO: What happens to the layout of the following when documentation is generated?
 * [ xAxis.x, xAxis.y, xAxis.z, 0]
 * [ yAxis.x, yAxis.y, yAxis.z, 0]
 * [ zAxis.x, zAxis.y, zAxis.z, 0]
 * [ trans.x, trans.y, trans.z, 1]
 * 
 * This function directly copies the input vectors; it does not
 * normalize or orthagonalize the axes.
 * 
 * @param xAxis the values to be copied to the first row of the matrix.
 * @param yAxis the values to be copied to the second row of the matrix.
 * @param zAxis the values to be copied to the third row of the matrix.
 * @param translation the values to be copied to the fourth row of the matrix.
 * @return the matrix that was constructed
 */
ARTransform3D ARTransform3DMakeFromAxesAndTranslation(ARPoint3D xAxis, ARPoint3D yAxis, ARPoint3D zAxis, ARPoint3D translation);

/**
 * Construct a transformation matrix given its x, y, and z axes, with no
 * translation (0,0,0).
 * 
 * @param xAxis the values to be copied to the first row of the matrix.
 * @param yAxis the values to be copied to the second row of the matrix.
 * @param zAxis the values to be copied to the third row of the matrix.
 * @param translation the values to be copied to the fourth row of the matrix.
 * @return the matrix that was constructed
 */
ARTransform3D ARTransform3DMakeFromAxes(ARPoint3D xAxis, ARPoint3D yAxis, ARPoint3D zAxis);

/**
 * Construct an orthogonal transformation matrix A with a translation
 * given by origin and oriented so that it faces the target in the
 * direction of the z axis. The upDirection determines the roll (rotation
 * around the z axis) of A.
 * 
 * This function assumes that origin != target and that upVector is not
 * parallel to (target - origin).
 * 
 * This function is equivalent to ARTransform3DLookAtRelative(origin, target - origin, upDirection)
 * 
 * @param origin the location of the object
 * @param target the location the object should look at
 * @param upDirection a vector pointing upwards, to determine the roll of the object. Its length does not matter.
 * @return the matrix that was constructed
 */
ARTransform3D ARTransform3DLookAt(ARPoint3D origin, ARPoint3D target, ARPoint3D upDirection);

/**
 * Construct an orthogonal transformation matrix A with a translation
 * given by origin and oriented so that it faces the target in the
 * direction of the z axis. The upDirection determines the roll (rotation
 * around the z axis) of A.
 * 
 * This function assumes that targetDirection and that upDirection is not
 * parallel to targetDirection.
 * 
 * @param origin the location of the object
 * @param targetDirection a vector pointing in the direction of the target.
 * @param upDirection a vector pointing upwards, to determine the roll of the object. Its length does not matter.
 * @return the matrix that was constructed
 */
ARTransform3D ARTransform3DLookAtRelative(ARPoint3D origin, ARPoint3D targetDirection, ARPoint3D upDirection);

/**
 * Transposes the matrix, changing rows into columns and vice-versa.
 * For an orthogonal matrix, the result is equivalent to inversing the
 * matrix.
 * 
 * @param transform the matrix to transform.
 * @result the transformed matrix
 */
ARTransform3D ARTransform3DTranspose(ARTransform3D transform);
