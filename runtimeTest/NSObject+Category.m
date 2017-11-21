//
//  NSObject+Category.m
//  runtimeTest
//
//  Created by daoquan on 2017/8/17.
//  Copyright © 2017年 daoquan. All rights reserved.
//

#import "NSObject+Category.h"
#import <objc/runtime.h>
#import <objc/message.h>

char *key = "name";

@implementation NSObject(Category)

- (void)setName:(NSString *)name {
    // 将某个值跟某个对象关联起来，将某个值存储到某个对象中 与key关联
    
    /* 
     set方法，将值value 跟对象object 关联起来（将值value 存储到对象object 中）
     参数 object：给哪个对象设置属性
     参数 key：一个属性对应一个Key，将来可以通过key取出这个存储的值，key 可以是任何类型：double、int 等，建议用char 可以节省字节
     参数 value：给属性设置的值
     参数policy：存储策略 （assign 、copy 、 retain就是strong）

    */
    objc_setAssociatedObject(self, key, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*)name {
    // 利用参数key， 取出某个对象 key 所对应的值
    return objc_getAssociatedObject(self, key);
}

@end
