//
//  NSObject+Log_Properties.m
//  Custom Alerts
//
//  Created by Richard Rindfuss on 8/7/17.
//  Copyright © 2017 Rich Rindfuss. All rights reserved.
//

#import "NSObject+Log_Properties.h"
#import <objc/runtime.h>

@implementation NSObject (Log_Properties)
- (void) logProperties {
    
    NSLog(@"----------------------------------------------- Properties for object %@", self);
    
    @autoreleasepool {
        unsigned int numberOfProperties = 0;
        objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
        for (NSUInteger i = 0; i < numberOfProperties; i++) {
            objc_property_t property = propertyArray[i];
            NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
            NSLog(@"Property %@ Value: %@", name, [self valueForKey:name]);
        }
        free(propertyArray);
    }
    NSLog(@"-----------------------------------------------");
}
@end
