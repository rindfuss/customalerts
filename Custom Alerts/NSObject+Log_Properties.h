//
//  NSObject+Log_Properties.h
//  Custom Alerts
//
//  Created by Richard Rindfuss on 8/7/17.
//  Copyright © 2017 Rich Rindfuss. All rights reserved.
//
// Adds a method to NSOjbects so that they can output their properties and values to the console
// Code comes from user tieme on stackoverflow

#import <Foundation/Foundation.h>

@interface NSObject (Log_Properties)
- (void) logProperties;
@end

