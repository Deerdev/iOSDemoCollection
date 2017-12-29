//
//  NSObject+JSONExtension.m
//  runtimeTest
//
//  Created by daoquan on 2017/8/21.
//  Copyright © 2017年 daoquan. All rights reserved.
//

#import "NSObject+JSONExtension.h"
#import <objc/runtime.h>

@implementation NSObject(JSONExtension)

/*
 {
 "name": "BatMan",
 "age": 28,
 "height": "175",
 // 1-字典包含的key 在模型中没有
 "weight": "75",
 // 2-字典嵌套 另一个字典
 "cat": {
    "name": "vivia",
    "color": "black",
    // 2-字典嵌套 另一个字典
    "food": {
        "name": "fish",
        "weight": "7.5g",
        "price": "25"
    }
 },
 // 3-字典包含 一个对象“数组”
 "books": [
            {
                "name": "C Language",
                "pages": "200",
                "price": "33"
            },
            {
                "name": "Thinking in Java",
                "pages": "600",
                "price": "109"
            }
        ]
 }
 */

/**
 应对 解析三种情况的字典：
    1-字典包含的key 在模型中没有
    2-字典嵌套 另一个字典
    3-字典包含 一个对象“数组”

 @param dict 字典
 */

- (void)setDict:(NSDictionary *)dict {
    Class c = self.class;
    
    while (c && c != [NSObject class]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList(c, &count);
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivars[i];
            // 获取成员变量名，包含下划线 _age
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            // 成员变量名 改为 属性名 （去除下划线_）
            key = [key substringFromIndex:1];
            // 取出字典值
            id value = dict[key];
            
            // 模型中的属性 字典中没有
            if (value == nil) {
                continue;
            }
            
            // 获取属性类型
            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
            // 如果属性类型 是对象（针对情况2-）,对象的类型 包含"@"
            NSRange range = [type rangeOfString:@"@"];
            if (range.location != NSNotFound) {
                // 截取出对象的完整名称（去除@，@"Cat" -> "Cat"）
                // 去除 [@, ", "] 共3个字符
                type = [type substringWithRange:NSMakeRange(2, type.length-3)];
                // 排除type的类型 是 系统类型
                if (![type hasPrefix:@"NS"]) {
                    // 将对象名称转为 对象的类型class， 继续 递归转换 该类型
                    Class class = NSClassFromString(type);
                    value = [class objectWithDict:value];
                } else if ([type isEqualToString:@"NSArray"]) {
                    // 数组类型（针对情况3-），将数组中的 每一个模型 进行转换；
                    // 使用临时数组 存放 转换后的模型值
                    NSArray *array = (NSArray*)value;
                    NSMutableArray *tmpArray = [NSMutableArray array];
                    
                    // 获取数组中存放的 对象类型
                    Class class;
                    if ([self respondsToSelector:@selector(arrayObjectClass)]) {
                        NSString *className = [self arrayObjectClass];
                        class = NSClassFromString(className);
                    }
                    // 将数组中的所有模型 进行 字典转换， 再存储到临时数组中
                    for (int i = 0; i < array.count; i++) {
                        [tmpArray addObject:[class objectWithDict:value[i]]];
                    }
                    
                    value = tmpArray;
                }
            }
            
            // 将字典的值 设置到模型上
            [self setValue:value forKey:key];
        }
        free(ivars);
        c = [c superclass];
    }
}


/**
 通过字典创建 模型实例

 @param dict 字典
 @return 实例
 */
+ (instancetype)objectWithDict:(NSDictionary*)dict {
    NSObject *obj = [[self alloc] init];
    [obj setDict:dict];
    return obj;
}

@end
