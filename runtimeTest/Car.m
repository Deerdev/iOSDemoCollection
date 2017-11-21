//
//  Car.m
//  runtimeTest
//
//  Created by daoquan on 2017/8/18.
//  Copyright © 2017年 daoquan. All rights reserved.
//

#import "Car.h"
#import "NSObject+Extension.h"
#import "CodeDefine.h"

@implementation Car

- (NSArray*)ignoredNames {
    return @[@"color"];
}

// 在系统方法内 调用自定义的归解档方法  快速实现归解档
//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    if (self = [super init]) {
//        [self decode:aDecoder];
//    }
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [self encode:aCoder];
//}

// 使用宏定义
CodingImplementation

@end
