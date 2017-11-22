//
//  QRCodeScanVC.h
//  QRCodeTest
//
//  Created by daoquan on 16/9/12.
//  Copyright © 2016年 feixun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeScanVC : UIViewController

/**
 初始化二维码扫描
 
 @param title 标题
 @param isAblum 是否显示相册
 @param isFlash 是否显示闪光灯
 @return self
 */

- (instancetype)initWithTitle:(NSString*)title isAlbum:(BOOL)isAblum isFlash:(BOOL)isFlash;

@end
