//
//  QRCodeScanVC.m
//  QRCodeTest
//
//  Created by daoquan on 16/9/12.
//  Copyright © 2016年 feixun. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "QRCodeScanVC.h"

@interface QRCodeScanVC ()
<
UIAlertViewDelegate,
AVCaptureMetadataOutputObjectsDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>

// 二维码扫描会话
@property (nonatomic, strong) AVCaptureSession *session;
// 二维码扫描窗口
@property (nonatomic, strong) UIView           *scanWindow;
// 二维码扫描动画图片
@property (nonatomic, strong) UIImageView      *scanNetImageView;
// 二维码扫描结果字符串
@property (nonatomic, strong) NSString         *QRCodeString;

@end

@implementation QRCodeScanVC

/**
 *  初始化View
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 这个属性必须打开否则返回的时候会出现黑边
    self.view.clipsToBounds = YES;
    self.title              = @"二维码";
    _QRCodeString           = nil;
    
    // 1.设置遮罩和提示文本
    [self setupMaskAndTitleView];
    // 2.顶部导航
    [self setupNavView];
    // 3.扫描区域
    [self setupScanWindowView];
    // 4.开始动画
    [self beginScanning];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(QRScanAnimation) name:@"EnterForeground" object:nil];
    NSLog(@"code0: %@", _QRCodeString);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  开启动画
 */
-(void)viewWillAppear:(BOOL)animated{
    [self QRScanAnimation];
}

/**
 *  处理字符串
 */
-(void)viewDidDisappear:(BOOL)animated{
    _session = nil;
    NSLog(@"code1: %@", _QRCodeString);
}

/**
 *  设置二维码扫描框和提示文字
 */
- (void)setupMaskAndTitleView{
    // 1.设置遮罩
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    CGSize scanSize   = CGSizeMake(windowSize.width*3/4, windowSize.width*3/4);
    
    UIView *maskView           = [[UIView alloc]init];
    maskView.bounds            = CGRectMake(0, 0, windowSize.height, windowSize.height);
    // 遮罩使用边框的颜色遮盖，保证中间是透明的
    maskView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    maskView.layer.borderWidth = (windowSize.height - scanSize.height)/2.0;
    maskView.center            = CGPointMake(self.view.bounds.size.width * 0.5, self.view.frame.size.height * 0.5);
    [self.view addSubview:maskView];
    // 实际的二维码扫描窗口
    UIView *scanView         = [[UIView alloc]initWithFrame:CGRectMake(0, 0, scanSize.width, scanSize.height)];
    scanView.backgroundColor = [UIColor clearColor];
    scanView.center          = CGPointMake(self.view.bounds.size.width * 0.5, self.view.frame.size.height * 0.5);
    _scanWindow              = scanView;
    [self.view addSubview:_scanWindow];
    
    
    // 2.二维码扫描提示
    UILabel * tipLabel       = [[UILabel alloc] initWithFrame:CGRectMake(0, _scanWindow.frame.origin.y + _scanWindow.frame.size.height, self.view.bounds.size.width, 50)];
    tipLabel.text            = @"将取景框对准二维码/条码，即可自动扫描";
    tipLabel.textColor       = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    tipLabel.textAlignment   = NSTextAlignmentCenter;
    tipLabel.lineBreakMode   = NSLineBreakByWordWrapping;
    tipLabel.numberOfLines   = 2;
    tipLabel.font            = [UIFont systemFontOfSize:14];
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLabel];
}

/**
 *  设置导航栏按钮--返回--相册--闪光灯（待定）--
 */
- (void)setupNavView{
    //1.返回按钮
    UIButton *backBtn                  = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame                      = CGRectMake(0, 0, 25, 25);
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn setBackgroundImage:[UIImage imageNamed:@"nav_back_orange"] forState:UIControlStateNormal];
    //backBtn.contentMode=UIViewContentModeScaleAspectFit;
    [backBtn addTarget:self action:@selector(backToPop) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem             = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    //leftItem.imageInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //2.相册按钮
    UIButton * albumBtn                    = [UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.frame                         = CGRectMake(0, 0, 50, 35);
    [albumBtn setTitle:@"相册" forState:UIControlStateNormal];
    albumBtn.titleLabel.font               = [UIFont systemFontOfSize:15];
    [albumBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    albumBtn.contentHorizontalAlignment     = UIControlContentHorizontalAlignmentRight;
    //albumBtn.contentMode=UIViewContentModeScaleAspectFit;
    [albumBtn addTarget:self action:@selector(readAlbum) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem             = [[UIBarButtonItem alloc]initWithCustomView:albumBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
//    //3.闪光灯
//    
//    UIButton * flashBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    flashBtn.frame = CGRectMake(self.view.sd_width-55,20, 35, 49);
//    [flashBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
//    flashBtn.contentMode=UIViewContentModeScaleAspectFit;
//    [flashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:flashBtn];
}

/**
 *  设置框四个边角的图片
 */
- (void)setupScanWindowView{
    CGFloat scanWindowH       = _scanWindow.frame.size.width;
    CGFloat scanWindowW       = _scanWindow.frame.size.width;
    _scanWindow.clipsToBounds = YES;

    // 初始化动画图片
    _scanNetImageView         = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_net"]];
    
    // 设置边角图片的高宽
    CGFloat buttonWH          = 18;

    // 添加四个边角图片
    UIButton *topLeft         = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWH, buttonWH)];
    [topLeft setImage:[UIImage imageNamed:@"scan_1"] forState:UIControlStateNormal];
    [_scanWindow addSubview:topLeft];

    UIButton *topRight        = [[UIButton alloc] initWithFrame:CGRectMake(scanWindowW - buttonWH, 0, buttonWH, buttonWH)];
    [topRight setImage:[UIImage imageNamed:@"scan_2"] forState:UIControlStateNormal];
    [_scanWindow addSubview:topRight];

    UIButton *bottomLeft      = [[UIButton alloc] initWithFrame:CGRectMake(0, scanWindowH - buttonWH + 2, buttonWH, buttonWH)];
    [bottomLeft setImage:[UIImage imageNamed:@"scan_3"] forState:UIControlStateNormal];
    [_scanWindow addSubview:bottomLeft];

    UIButton *bottomRight     = [[UIButton alloc] initWithFrame:CGRectMake(topRight.frame.origin.x, scanWindowH - buttonWH + 2, buttonWH, buttonWH)];
    [bottomRight setImage:[UIImage imageNamed:@"scan_4"] forState:UIControlStateNormal];
    //[bottomLeft.layer setBorderWidth:1.0];
    [_scanWindow addSubview:bottomRight];
}

/**
 *  初始化二维码扫描
 */
- (void)beginScanning{
    // 获取摄像设备
    AVCaptureDevice * device     = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    // 没有摄像头--返回
    if (!input) return;
    
    // 创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    // 设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 设置有效扫描区域
    CGRect scanCrop       = [self getScanCrop:_scanWindow.bounds readerViewBounds:self.view.frame];
    output.rectOfInterest = scanCrop;

    // 初始化会话对象
    _session = [[AVCaptureSession alloc]init];
    // 高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];

    // 关联输入输出
    [_session addInput:input];
    [_session addOutput:output];
    
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];

    // 初始化摄像头流信息显示图层
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity                 = AVLayerVideoGravityResizeAspectFill;
    layer.frame                        = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    // 开始捕获
    [_session startRunning];
}

/**
 *  获取二维码扫描结果
 *
 *  @param captureOutput   流输出
 *  @param metadataObjects 元数据
 *  @param connection      流连接
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if ( (metadataObjects.count==0) )
    {
        return;
    }
    if (metadataObjects.count>0) {
        // 停止会话
        [_session stopRunning];
        // 获取扫描数据
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        
        // 赋值字符串
        _QRCodeString = metadataObject.stringValue;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:metadataObject.stringValue message:@"" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
}

/**
 *  返回到上一个视图
 */
- (void)backToPop{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  读取本地图片
 */
- (void)readAlbum{
    NSLog(@"我的相册");
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
        // 1.初始化相册拾取器
        UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
        // 2.设置代理
        photoPicker.delegate = self;
        // 3.设置资源：
        /**
         UIImagePickerControllerSourceTypePhotoLibrary,相册
         UIImagePickerControllerSourceTypeCamera,相机
         UIImagePickerControllerSourceTypeSavedPhotosAlbum,照片库
         */
        photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 4.随便给他一个转场动画
        photoPicker.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:photoPicker animated:YES completion:NULL];
        
    } else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - imagePickerController delegate
/**
 *  读取选择的图片进行二维码识别
 *
 *  @param picker 图片选择控制器
 *  @param info   选择数据
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 1.获取选择的图片
    UIImage *srcImage       = info[UIImagePickerControllerOriginalImage];
    // 2.初始化一个监测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        // 监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:srcImage.CGImage]];
        
        if ( features.count >= 1 ) {
            // 结果对象
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult  = feature.messageString;
            // 赋值字符串
            _QRCodeString = scannedResult;
            
            UIAlertView * alertView  = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

#pragma mark - UIAlertViewDelegate
/**
 *  弹窗点击事件
 *
 *  @param alertView   弹窗
 *  @param buttonIndex 点击按钮索引
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self backToPop];
    } else if (buttonIndex == 1) {
        [_session startRunning];
    }
}

#pragma mark - 动画
/**
 *  二维码扫描动画
 */
- (void)QRScanAnimation
{
    CAAnimation *anim = [_scanNetImageView.layer animationForKey:@"translationAnimation"];
    if(anim){
        // 1.将动画的时间偏移量作为暂停时的时间点
        CFTimeInterval pauseTime = _scanNetImageView.layer.timeOffset;
        // 2.根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
        CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime;
        
        // 3.要把偏移时间清零
        [_scanNetImageView.layer setTimeOffset:0.0];
        // 4.设置图层的开始动画时间
        [_scanNetImageView.layer setBeginTime:beginTime];
        
        [_scanNetImageView.layer setSpeed:1.0];
        
    }else{
        
        CGFloat scanNetImageViewH = 241;
        CGFloat scanWindowH       = self.view.frame.size.width;
        CGFloat scanNetImageViewW = _scanWindow.frame.size.width;
        
        _scanNetImageView.frame            = CGRectMake(0, -scanNetImageViewH, scanNetImageViewW, scanNetImageViewH);
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath           = @"transform.translation.y";
        scanNetAnimation.byValue           = @(scanWindowH);
        scanNetAnimation.duration          = 1.0;
        scanNetAnimation.repeatCount       = MAXFLOAT;
        [_scanNetImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
        [_scanWindow addSubview:_scanNetImageView];
    }
}

#pragma mark - 获取扫描区域的比例关系
/**
 *  设置二维码扫描的有效区域（即扫描遮罩的大小）
 *
 *  @param rect             扫描遮罩的大小
 *  @param readerViewBounds 全局（摄像头画面）视图大小
 *
 *  @return 二维码扫描的实际区域（一个比例系数的矩形）
 */
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    
    x      = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y      = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width  = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    
    return CGRectMake(x, y, width, height);
}

@end
