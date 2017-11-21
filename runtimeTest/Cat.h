//
//  Cat.h
//  runtimeTest
//
//  Created by daoquan on 2017/8/21.
//  Copyright © 2017年 daoquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Food;

@interface Cat : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, strong) Food *food;

@end
