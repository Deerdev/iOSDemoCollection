//
//  NSObject+Extension.h
//  runtimeTest
//
//  Created by daoquan on 2017/8/18.
//  Copyright © 2017年 daoquan. All rights reserved.
//

/*
 一个对象在归档和解档的 encodeWithCoder和initWithCoder:方法中需要该对象所有的属性进行decodeObjectForKey: 和 encodeObject:，
 通过runtime我们声明中无论写多少个属性，都不需要再修改实现中的代码
 */
#import <Foundation/Foundation.h>

@interface NSObject(Extension)

- (NSArray *)ignoredNames;
- (void)encode:(NSCoder *)aCoder;
- (void)decode:(NSCoder *)aDecoder;

@end
