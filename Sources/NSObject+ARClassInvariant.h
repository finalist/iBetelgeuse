//
//  NSObject+ARClassInvariant.h
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

#import <Foundation/Foundation.h>


// If assertions are not blocked, add macros for class invariant
#ifndef NS_BLOCK_ASSERTIONS

// The ARAssertClassInvariant macro can be used to assert the class invariant holds within a class implementation
#define ARAssertClassInvariant() [self ar_assertClassInvariantHolds]

// The ARAssertClassInvariant macro can be used to assert the class invariant of a certain object
#define ARAssertClassInvariantOfObject(obj) [obj ar_assertClassInvariantHolds]

// The ARSuperClassInvariant can be used to get the super class invariant within a class implementation
#define ARSuperClassInvariant [super ar_classInvariant]

// The ARDefineClassInvariant can be used to define the class invariant within a class implementation
#define ARDefineClassInvariant(cond) - (BOOL)ar_classInvariant { return (cond); }

@interface NSObject (ARClassInvariant)

- (BOOL)ar_classInvariant;
- (void)ar_assertClassInvariantHolds;

@end

#else

#define ARAssertClassInvariant()
#define ARAssertClassInvariantOfObject(obj)
#define ARSuperClassInvariant
#define ARDefineClassInvariant(cond)

#endif
