//
//  Person.m
//  runtimeTest
//
//  Created by daoquan on 2017/8/17.
//  Copyright © 2017年 daoquan. All rights reserved.
//

#import "Person.h"

@implementation Person

+ (void)run {
    NSLog(@"run");
}

+ (void)work {
    NSLog(@"work");
}

- (void)run2 {
    NSLog(@"run2");
}

- (void)work2 {
    NSLog(@"work2");
}


- (NSString*)arrayObjectClass {
    return @"Book";
}

@end
