//
//  CopyInObjc.m
//  InterviewTest_OC
//
//  Created by daoquan on 2018/7/14.
//  Copyright © 2018年 deerdev. All rights reserved.
//

#import "CopyInObjc.h"

@interface CopyInObjc()

@property(nonatomic, strong) NSString *strongStr;
@property(nonatomic, copy) NSString *copyStr;
@property(nonatomic, copy) NSMutableString * muteString;

@end

@implementation CopyInObjc

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)testCopy {
    _strongStr = @"strong string";
    NSLog(@"string0: %p", _strongStr);

    // 浅拷贝，地址没有发生变化(copy 也是)
    NSString *tmpString = _strongStr;
    NSLog(@"tmpString-1: %p", tmpString);
    tmpString = [_strongStr copy];
    NSLog(@"tmpString-2: %p", tmpString);

    // ----
    _muteString = [NSMutableString stringWithFormat:@"mute String"];
    NSLog(@"muteString: %p", _muteString);
    // 深拷贝，地址发生变化
    NSMutableString *copyMuteString = [_muteString copy];
    NSLog(@"copy MuteString: %p", copyMuteString);

    // crash -[NSTaggedPointerString appendString:]: unrecognized selector sent to instance 0xa1a0403e842857ab
    // 拷贝出来的是不可变数组
//    [copyMuteString appendString:@"test"];


    // ------

    // 深拷贝
    tmpString = [_strongStr mutableCopy];
    NSLog(@"tmpString mutablecopy: %p", tmpString);
    // 深拷贝，并且是可变字符串
    copyMuteString = [_muteString mutableCopy];
    NSLog(@"mutablecopy MuteString: %p", copyMuteString);
    [copyMuteString appendString:@"-test"];
    NSLog(@"mutablecopy MuteString: %p - %@", copyMuteString, copyMuteString);

    //Con: 1. copy出来的字符串一定是不可变字符串，如果传入的是可变字符串，会发生"深拷贝"为不可变字符串，否则为浅拷贝。
    //     2. mutablecopy，一定是深拷贝，拷贝出来的一定是"可变字符串或者数组"，即使传入的是"不可变字符串或者数组"。
}

- (void)testPropertyCopy {
    NSMutableString *muteString = [NSMutableString stringWithString:@"mutable string"];
    NSLog(@"muteString: %p", muteString);   // 0x604000245010
    _strongStr = muteString;
    // 必须使用self才能触发属性copy（_copyStr赋值，还是浅拷贝, 和_strongStr一样）
    self.copyStr = muteString;

    NSLog(@"string0: %p - %@", _strongStr, _strongStr); // string0: 0x604000245010 - mutable string
    NSLog(@"string1: %p - %@", _copyStr, _copyStr); // string1: 0x60400022c4a0 - mutable string
    [muteString appendString:@" append new"];   // 0x604000245010
    NSLog(@"muteString: %p", muteString);

    NSLog(@"string0 after append: %p - %@", _strongStr, _strongStr);    // string0 after append: 0x604000245010 - mutable string append new
    NSLog(@"string1 after append: %p - %@", _copyStr, _copyStr);    // string1 after append: 0x60400022c4a0 - mutable string


    // Con: NSString使用copy修饰之后，即使属性拷贝来自[可变字符串]，也会被深拷贝成[不可变字符串]，也就是源字符串修改之后不会影响到属性字符串，增强了代码的健壮性。
    //      关于不可变字符串和数组的copy是浅拷贝也很好理解，既然数据源本身是不可变的，也就是具备安全性，那么系统默认浅拷贝其中数据，显然是合理的做法。
}


@end
