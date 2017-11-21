//
//  ViewController.m
//  QRCodeTest
//
//  Created by daoquan on 16/9/12.
//  Copyright © 2016年 daoquan. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeScanVC.h"

@interface ViewController ()

@property(nonatomic, strong)UIButton *scanbtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _scanbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_scanbtn setTitle:@"扫描" forState:UIControlStateNormal];
    [_scanbtn setBackgroundColor:[UIColor orangeColor]];
    [_scanbtn addTarget:self action:@selector(startScan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_scanbtn];
    
    _scanbtn.frame = CGRectMake(0, 0, 80, 40);
    _scanbtn.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-> 二维码扫描
-(void)startScan{
    QRCodeScanVC *scanVC = [[QRCodeScanVC alloc]init];
//    Scan_VC*vc=[[Scan_VC alloc]init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

@end
