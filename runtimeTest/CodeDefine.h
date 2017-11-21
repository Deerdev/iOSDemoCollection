//
//  CodeDefine.h
//  runtimeTest
//
//  Created by daoquan on 2017/8/18.
//  Copyright © 2017年 daoquan. All rights reserved.
//

// 通过宏定义来实现归解档
#import "NSObject+Extension.h"

#define CodingImplementation \
- (instancetype)initWithCoder:(NSCoder *)aDecoder {\
if (self = [super init]) {\
[self decode:aDecoder];\
}\
return self;\
}\
\
- (void)encodeWithCoder:(NSCoder *)aCoder {\
[self encode:aCoder];\
}
