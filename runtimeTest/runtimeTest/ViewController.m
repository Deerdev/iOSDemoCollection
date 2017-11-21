//
//  ViewController.m
//  runtimeTest
//
//  Created by daoquan on 2017/8/17.
//  Copyright © 2017年 daoquan. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "Person.h"
#import "NSObject+Category.h"
#import "Fish.h"


/*
 参考链接：
 http://www.jianshu.com/p/ab966e8a82e2
 http://www.jianshu.com/p/e071206103a4
 */

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self changeMethod_UsingRuntime];
    [self loadMyImagemethod_UsingRuntime];
    [self addPropertyToNSObject_UsingRuntime];
    [self addMethod_UsingRuntime];
    [self listAllPropertyOfClass_UsingRuntime];
}

/**
 交换类方法、实例方法
 */
- (void)changeMethod_UsingRuntime {
    // 交换类方法
    [Person run];
    [Person work];
    // 获取 类的类方法
    Method m1 = class_getClassMethod([Person class], @selector(run));
    Method m2 = class_getClassMethod([Person class], @selector(work));
    // 交换方法实现
    method_exchangeImplementations(m1, m2);
    [Person run];
    [Person work];
    
    // 交换实例方法
    Person *p = [[Person alloc] init];
    [p run2];
    [p work2];
    
    // 获得 类的实例对象方法
    Method m21 = class_getInstanceMethod([Person class], @selector(run2));
    Method m22 = class_getInstanceMethod([Person class], @selector(work2));
    // 交换方法实现
    method_exchangeImplementations(m21, m22);
    
    [p run2];
    [p work2];
}

/**
 拦截实例方法，添加自定义步骤
 */
- (void)loadMyImagemethod_UsingRuntime {
    UIImage *image = [UIImage imageNamed:@"iconShoping"];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    [view setFrame:CGRectMake(50, 50, 100, 100)];
    [self.view addSubview:view];
}


/**
 NSObject+Category.h
 为类添加 属性(所有集成NSObject的类 都添加了name属性)
 */
- (void)addPropertyToNSObject_UsingRuntime {
    Person *p = [[Person alloc] init];
    p.name = @"Person new";
    NSLog(@"%@", p.name);
    UIImage *m = [[UIImage alloc] init];
    m.name = @"Image new";
    NSLog(@"%@", m.name);
}


/**
 动态添加 方法，Fish.h
 */
- (void)addMethod_UsingRuntime {
    Fish *f = [[Fish alloc] init];
    // 默认person，没有实现eat方法，可以通过performSelector调用，但是会报错。
    // 动态添加方法就不会报错
    [f performSelector:@selector(eat)];
    // 第二次调用，不用再注册，此时直接调用eat方法
    [f performSelector:@selector(eat)];
}

/**
 列举出一个类的所有属性
 */
/* 
 最典型的用法就是一个对象在归档和解档的 encodeWithCoder和initWithCoder:方法中需要该对象所有的属性进行decodeObjectForKey: 和 encodeObject:，
 通过runtime我们声明中无论写多少个属性，都不需要再修改实现中的代码了。
 */
- (void)listAllPropertyOfClass_UsingRuntime {
    unsigned int count = 0;
    
    /*
     获得某个类的所有成员变量（outCount 会返回成员变量的总数）
     参数：
     1、哪个类
     2、放一个接收值的地址，用来存放属性的个数
     3、返回值：存放所有获取到的属性，通过下面两个方法可以调出名字和类型
     */
    Ivar *ivars = class_copyIvarList([Person class], &count);
    for (int i = 0; i < count; ++i) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        NSLog(@"成员变量名：%s，成员变量类型：%s", name, type);
    }
    
    free(ivars);
}

@end










