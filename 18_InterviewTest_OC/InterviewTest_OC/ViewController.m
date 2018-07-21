//
//  ViewController.m
//  InterviewTest_OC
//
//  Created by daoquan on 2018/7/14.
//  Copyright © 2018年 deerdev. All rights reserved.
//

#import "ViewController.h"
#import "CopyInObjc.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CopyInObjc *test = [[CopyInObjc alloc] init];
//    [test testCopy];
    [test testPropertyCopy];
}

@end
