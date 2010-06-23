//
//  UIDevice+ARDevice.h
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

#import <UIKit/UIKit.h>


/**
 * Category on UIDevice that adds a method for determining the exact model identifier of the device.
 */
@interface UIDevice (ARDevice)

/**
 * The model identifier of the receiver. This method may only be called on the instance returned by the currentDevice class method. The value may be nil and is undefined on the iPhone Simulator.
 *
 * Known model identifiers are:
 * iPhone3,1	iPhone 4
 * iPhone2,1	iPhone 3GS
 * iPhone1,2	iPhone 3G
 * iPhone1,1	iPhone (original)
 * iPod3,1		iPod touch (3rd generation)
 * iPod2,1		iPod touch (2nd generation)
 * iPod1,1		iPod touch (original)
 * iPad1,1		iPad
 */
@property(nonatomic, readonly, retain) NSString *ar_modelIdentifier;

@end
