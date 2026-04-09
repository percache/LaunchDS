//
//  Bridge.m
//  AntoineDS
//

#import <Foundation/Foundation.h>

NSString * _Nonnull antoineGetBuildDate(void) {
    return @__DATE__;
}

NSString * _Nonnull antoineGetBuildTime(void) {
    return @__TIME__;
}
