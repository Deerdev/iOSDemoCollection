//
//  UIImage+Category.m
//  runtimeTest
//
//  Created by daoquan on 2017/8/17.
//  Copyright © 2017年 daoquan. All rights reserved.
//

#import "UIImage+Category.h"
#import <objc/message.h>

@implementation UIImage(Category)

+ (UIImage *)xxxx_imageNamed:(NSString*)name {
    NSLog(@"using xxxxImageMethod");
    
    // 注意：自定义方法中最后一定要再调用一下系统的方法，让其有加载图片的功能，
    // 但是由于方法交换，系统的方法名已经变成了我们自定义的方法名（有点绕，就是用我们的名字能调用系统的方法，用系统的名字能调用我们的方法），
    // 这就实现了系统方法的拦截！
    return [UIImage xxxx_imageNamed:name];
}


/**
 重写 load 默认方法
 */
+ (void)load {
    Method m1 = class_getClassMethod([UIImage class], @selector(imageNamed:));
    Method m2 = class_getClassMethod([UIImage class], @selector(xxxx_imageNamed:));
    
    method_exchangeImplementations(m1, m2);
}

@end
