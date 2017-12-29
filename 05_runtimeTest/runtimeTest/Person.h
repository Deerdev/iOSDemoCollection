//
//  Person.h
//  runtimeTest
//
//  Created by daoquan on 2017/8/17.
//  Copyright © 2017年 daoquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Cat;
@class Book;

@interface Person : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign) int *age;
@property(nonatomic, copy) NSString *male;
@property(nonatomic, strong) Cat *cat;
@property(nonatomic, strong) NSArray<Book*> *books;


+ (void)run;

+ (void)work;


- (void)run2;

- (void)work2;

@end
