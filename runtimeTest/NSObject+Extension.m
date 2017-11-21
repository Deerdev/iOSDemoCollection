//
//  NSObject+Extension.m
//  runtimeTest
//
//  Created by daoquan on 2017/8/18.
//  Copyright © 2017年 daoquan. All rights reserved.
//

#import "NSObject+Extension.h"
#import <objc/runtime.h>

@implementation NSObject(Extension)


/**
 归档时 忽略的属性（不用归档）

 @return 属性名数组
 */
// 子类选择实现
//- (NSArray *)ignoredNames {
//    return @[@"name", @"name2"];
//}


/**
 归档
 */
- (void)encode:(NSCoder *)aCoder {
    Class c = self.class;
    
    // 一直向上查找父类，对父类进行归档，知道NSObject方法
    while (c && c != [NSObject class]) {
        unsigned int count = 0;
        
        Ivar *ivars = class_copyIvarList(c, &count);
        // 变量获取成员变量名
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivars[i];
            // 将每个成员变量转换为NSString对象类型
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            
            // 实现该方法再去调用
            if ([self respondsToSelector:@selector(ignoredNames)]) {
                // 忽略不需要归档的属性
                if ([[self ignoredNames] containsObject:key]) {
                    continue;
                }
            }
            
            // 通过成员变量名，去除成员变量的值
            id value = [self valueForKey:key];
            // 归档
            [aCoder encodeObject:value forKey:key];
        }
        
        // 释放内存
        free(ivars);
        c = [c superclass];
    }
}


/**
 解档
 */
- (void)decode:(NSCoder *)aDecoder {
    Class c = self.class;
    
    // 一直向上查找父类，对父类进行归档，知道NSObject方法
    while (c && c != [NSObject class]) {
        unsigned int count = 0;
        
        Ivar *ivars = class_copyIvarList(c, &count);
        // 变量获取成员变量名
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivars[i];
            // 将每个成员变量转换为NSString对象类型
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            // 实现该方法再去调用
            if ([self respondsToSelector:@selector(ignoredNames)]) {
                // 忽略不需要归档的属性
                if ([[self ignoredNames] containsObject:key]) {
                    continue;
                }
            }
            
            // 通过成员变量名，解档 成员变量值
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        
        // 释放内存
        free(ivars);
        c = [c superclass];
    }
}

@end
