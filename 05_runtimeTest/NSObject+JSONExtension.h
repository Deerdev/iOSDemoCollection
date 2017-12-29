//
//  NSObject+JSONExtension.h
//  runtimeTest
//
//  Created by daoquan on 2017/8/21.
//  Copyright © 2017年 daoquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(JSONExtension)


/**
 返回实例中 “数组”型属性 中 数组存放的数据类型

 @return 数据类型
 */
- (NSString*)arrayObjectClass;


/**
 字典 转 模型

 @param dict 字典
 */
- (void)setDict:(NSDictionary*)dict;
@end
