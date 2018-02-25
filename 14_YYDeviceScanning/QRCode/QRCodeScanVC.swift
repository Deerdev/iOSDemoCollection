//
//  QRCodeScanVC.swift
//  YYDeviceScanning
//
//  Created by daoquan on 2018/2/23.
//  Copyright © 2018年 deerdev. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeScanVC: UIViewController {

    /// 二维码扫描会话
    private var session: AVCaptureSession?
    /// 二维码扫描窗口
    private var scanWindow: UIView!
    /// 二维码扫描动画图片
    private var scanNetImageView: UIImageView!
    /// 二维码扫描结果字符串
    private var qrCodeString: String?
    /// Controller的标题
    private var controllerTitle = ""
    /// 是否显示相册
    private var isShowAlbum = false
    /// 是否显示闪光灯
    private var isShowFlash = false
    /// 闪光灯是否在亮
    private var isFlashOn = false

    var scanResult: ((_ result: String) -> Void)?

    convenience init(with title: String, isShowAlbum: Bool, isShowFlash: Bool) {
        self.init()
        self.controllerTitle = title
        self.isShowAlbum = isShowAlbum
        self.isShowFlash = isShowFlash
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 这个属性必须打开否则返回的时候会出现黑边

        self.view.clipsToBounds = true
        self.title = controllerTitle
        // 1.设置遮罩和提示文本
        setupMaskAndTitleView()
        // 2.顶部导航
        setupNavView()
        // 3.扫描区域
        setupScanWindowView()
        // 4.检查权限
        verifyCameraAccess()
        // 5.开始动画
        //    [self beginScanning];
        NotificationCenter.default.addObserver(self, selector: #selector(self.qrScanAnimation), name: .UIApplicationWillEnterForeground, object: nil)
        print("code0: \(qrCodeString ?? "")")
        NotificationCenter.default.addObserver(self, selector: #selector(self.backBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)

    }

    /// 检查相机是否授权
    func verifyCameraAccess() {
        let AVstatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        //相机权限
        switch AVstatus {
        case .authorized:
            beginScanning()
        case .notDetermined:
            requireCameraAccess()
        case .denied, .restricted:
            showAccessAlert()
        }
    }

    /// 第一次请求授权
    func requireCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { (isGranted) in
            //相机权限
            if isGranted {
                DispatchQueue.main.async {
                    self.beginScanning()
                    self.qrScanAnimation()
                }
            }
        }
    }

    /// 请求用户开启权限的弹窗
    func showAccessAlert() {
        showAlert(title: "提示", message: "设备不支持访问相机，\n请在设置中打开相机访问！", cancelBlock: {}, isNeedConfirm: true, confirmTitle: "前往设置") {
            let appSettings = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.open(appSettings!)
        }
    }

    /// 后台进前台，激活动画
    @objc func backBecomeActive() {
        // 后台进前台，激活动画
        qrScanAnimation()
        if let session = session, !session.isRunning {
            session.startRunning()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 开启动画
        qrScanAnimation()
        if let session = session, !session.isRunning {
            session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        scanNetImageView.layer.removeAnimation(forKey: "translationAnimation")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let session = session {
            session.stopRunning()
        }
        closeFlash()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 设置二维码扫描框和提示文字
    func setupMaskAndTitleView() {
        // 1.设置遮罩
        let windowSize: CGSize = UIScreen.main.bounds.size
        let scanSize = CGSize(width: windowSize.width * 3 / 4, height: windowSize.width * 3 / 4)
        let maskView = UIView()
        maskView.bounds = CGRect(x: 0, y: 0, width: windowSize.height, height: windowSize.height)
        // 遮罩使用边框的颜色遮盖，保证中间是透明的
        maskView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        maskView.layer.borderWidth = (windowSize.height - scanSize.height) / 2.0
        maskView.center = CGPoint(x: view.bounds.size.width * 0.5, y: view.frame.size.height * 0.5)
        view.addSubview(maskView)
        // 实际的二维码扫描窗口
        let scanView = UIView(frame: CGRect(x: 0, y: 0, width: scanSize.width, height: scanSize.height))
        scanView.backgroundColor = UIColor.clear
        scanView.center = CGPoint(x: view.bounds.size.width * 0.5, y: view.frame.size.height * 0.5)
        scanWindow = scanView
        view.addSubview(scanWindow)
        // 2.二维码扫描提示
        let tipLabel = UILabel(frame: CGRect(x: 0, y: scanWindow.frame.origin.y + scanWindow.frame.size.height, width: view.bounds.size.width, height: 50))
        tipLabel.text = "将取景框对准二维码/条码，即可自动扫描"
        tipLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        tipLabel.textAlignment = .center
        tipLabel.lineBreakMode = .byWordWrapping
        tipLabel.numberOfLines = 2
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        tipLabel.backgroundColor = UIColor.clear
        view.addSubview(tipLabel)
    }

    /// 设置导航栏按钮--返回--相册--闪光灯（待定）--
    func setupNavView() {
        //1.返回按钮
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        backBtn.contentHorizontalAlignment = .left
        backBtn.setBackgroundImage(UIImage(named: "nav_back_orange"), for: .normal)
        //backBtn.contentMode=UIViewContentModeScaleAspectFit;
        backBtn.addTarget(self, action: #selector(self.backToPop), for: .touchUpInside)
        let leftItem = UIBarButtonItem(customView: backBtn)
        //leftItem.imageInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
        self.navigationItem.leftBarButtonItem = leftItem
        if isShowAlbum {
            //2.相册按钮
            let albumBtn = UIButton(type: .custom)
            albumBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 35)
            albumBtn.setTitle("相册", for: .normal)
            albumBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            albumBtn.setTitleColor(UIColor.orange, for: .normal)
            albumBtn.contentHorizontalAlignment = .right
            //albumBtn.contentMode=UIViewContentModeScaleAspectFit;
            albumBtn.addTarget(self, action: #selector(self.readAlbum), for: .touchUpInside)
            let rightItem = UIBarButtonItem(customView: albumBtn)
            self.navigationItem.rightBarButtonItem = rightItem
        }
        if isShowFlash {
            //3.闪光灯
            let flashBtn = UIButton(type: .custom)
            let flashImage = UIImage(named: "scan_flash")!
            flashBtn.frame = CGRect(x: 0, y: 0, width: 50, height: flashImage.size.height * (50 / flashImage.size.width))
            flashBtn.center = CGPoint(x: view.center.x, y: view.center.y + scanWindow.frame.size.height / 2 + 100)
            flashBtn.setBackgroundImage(flashImage, for: .normal)
            flashBtn.contentMode = .scaleAspectFit
            flashBtn.addTarget(self, action: #selector(self.openFlash), for: .touchUpInside)
            view.addSubview(flashBtn)
        }
    }

    /// 打开闪光灯
    @objc func openFlash() {
        let device: AVCaptureDevice? = AVCaptureDevice.default(for: .video)
        // 是否有LED
        if device?.hasTorch ?? false {
            if isFlashOn {
                try? device?.lockForConfiguration()
                device?.torchMode = .off
                //关
                device?.unlockForConfiguration()
            }
            else {
                try? device?.lockForConfiguration()
                device?.torchMode = .on
                //开
                device?.unlockForConfiguration()
            }
            isFlashOn = !isFlashOn
        }
        else {
            showAlert(title: "提示", message: "该手机不支持开启闪光灯")
        }
    }

    /// 关闭闪光灯
    func closeFlash() {
        if isShowFlash {
            let device: AVCaptureDevice? = AVCaptureDevice.default(for: .video)
            if device?.hasTorch ?? false {
                if isFlashOn {
                    try? device?.lockForConfiguration()
                    device?.torchMode = .off
                    //关
                    device?.unlockForConfiguration()
                    isFlashOn = false
                }
            }
        }
    }

    /// 设置框四个边角的图片
    func setupScanWindowView() {
        let scanWindowH: CGFloat = scanWindow.frame.size.width
        let scanWindowW: CGFloat = scanWindow.frame.size.width
        scanWindow.clipsToBounds = true
        // 初始化动画图片
        scanNetImageView = UIImageView(image: UIImage(named: "scan_net"))
        // 设置边角图片的高宽
        let image = UIImage(named: "scan_1")!
        let buttonWH: CGFloat = image.size.width
        // 添加四个边角图片
        let topLeft = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWH, height: buttonWH))
        topLeft.setImage(UIImage(named: "scan_1"), for: .normal)
        scanWindow.addSubview(topLeft)
        let topRight = UIButton(frame: CGRect(x: scanWindowW - buttonWH, y: 0, width: buttonWH, height: buttonWH))
        topRight.setImage(UIImage(named: "scan_2"), for: .normal)
        scanWindow.addSubview(topRight)
        let bottomLeft = UIButton(frame: CGRect(x: 0, y: scanWindowH - buttonWH, width: buttonWH, height: buttonWH))
        bottomLeft.setImage(UIImage(named: "scan_3"), for: .normal)
        scanWindow.addSubview(bottomLeft)
        let bottomRight = UIButton(frame: CGRect(x: topRight.frame.origin.x, y: scanWindowH - buttonWH, width: buttonWH, height: buttonWH))
        bottomRight.setImage(UIImage(named: "scan_4"), for: .normal)
        //[bottomLeft.layer setBorderWidth:1.0];
        scanWindow.addSubview(bottomRight)
    }

    /// 初始化二维码扫描
    func beginScanning() {
        // 获取摄像设备, 创建输入流
        guard let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device) else {
            // 没有摄像头--返回
            return
        }

        // 创建输出流
        let output = AVCaptureMetadataOutput()
        // 设置代理 在主线程里刷新
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // 设置有效扫描区域
        let scanCrop: CGRect = getScanCrop(scanWindow.bounds, readerViewBounds: view.frame)
        output.rectOfInterest = scanCrop
        // 初始化会话对象
        let session = AVCaptureSession()
        // 高质量采集率
        session.sessionPreset = .high
        // 关联输入输出
        session.addInput(input)
        session.addOutput(output)

        // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        output.metadataObjectTypes = [.qr, .ean13, .ean8, .code128]
        // 初始化摄像头流信息显示图层
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.layer.bounds
        view.layer.insertSublayer(layer, at: 0)
        // 开始捕获
        session.startRunning()

        self.session = session
    }

    /// 返回到上一个视图
    @objc func backToPop() {
        navigationController?.popViewController(animated: true)
    }

    /// 读取本地图片
    @objc func readAlbum() {
        print("我的相册")
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 1.初始化相册拾取器
            let photoPicker = UIImagePickerController()
            // 2.设置代理
            photoPicker.delegate = self
            // 3.设置资源：
            /**
             UIImagePickerControllerSourceTypePhotoLibrary,相册
             UIImagePickerControllerSourceTypeCamera,相机
             UIImagePickerControllerSourceTypeSavedPhotosAlbum,照片库
             */
            photoPicker.sourceType = .photoLibrary
            // 4.随便给他一个转场动画
            photoPicker.modalTransitionStyle = .flipHorizontal
            present(photoPicker, animated: true) {() -> Void in }
        }
        else {
            showAlert(title: "提示", message: "设备不支持访问相册，请在设置->隐私->照片中进行设置！", cancelBlock: backToPop)
        }
    }

    // MARK: - 动画

    /// 二维码扫描动画
    @objc func qrScanAnimation() {
        if let session = session, !session.isRunning {
            return
        }

        let anim: CAAnimation? = scanNetImageView.layer.animation(forKey: "translationAnimation")
        if anim != nil {
            // 1.将动画的时间偏移量作为暂停时的时间点
            let pauseTime: CFTimeInterval = scanNetImageView.layer.timeOffset
            // 2.根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
            let beginTime: CFTimeInterval = CACurrentMediaTime() - pauseTime
            // 3.要把偏移时间清零
            scanNetImageView.layer.timeOffset = 0.0
            // 4.设置图层的开始动画时间
            scanNetImageView.layer.beginTime = beginTime
            scanNetImageView.layer.speed = 2.5
        }
        else {
            let scanNetImageViewW: CGFloat = scanWindow.frame.size.width
            scanNetImageView.frame = CGRect(x: 0, y: 0, width: scanNetImageViewW, height: 2)
            let scanNetAnimation = CABasicAnimation()
            scanNetAnimation.keyPath = "transform.translation.y"
            scanNetAnimation.byValue = scanNetImageViewW
            scanNetAnimation.duration = 2
            scanNetAnimation.repeatCount = MAXFLOAT
            scanNetImageView.layer.add(scanNetAnimation, forKey: "translationAnimation")
            scanWindow.addSubview(scanNetImageView)
        }
    }

    // MARK: - 获取扫描区域的比例关系

    /// 设置二维码扫描的有效区域（即扫描遮罩的大小）
    ///
    /// - Parameters:
    ///   - rect: 扫描遮罩的大小
    ///   - readerViewBounds: 全局（摄像头画面）视图大小
    /// - Returns: 二维码扫描的实际区域（一个比例系数的矩形）
    func getScanCrop(_ rect: CGRect, readerViewBounds: CGRect) -> CGRect {
        var x: CGFloat
        var y: CGFloat
        var width: CGFloat
        var height: CGFloat
        x = (readerViewBounds.height - rect.height) / 2 / readerViewBounds.height
        y = (readerViewBounds.width - rect.width) / 2 / readerViewBounds.width
        width = rect.height / readerViewBounds.height
        height = rect.width / readerViewBounds.width
        return CGRect(x: x, y: y, width: width, height: height)
    }

    /// 弹窗
    func showAlert(title: String,
                   message: String,
                   cancelBlock: @escaping (() -> Void) = {},
                   isNeedConfirm: Bool = false,
                   confirmTitle: String = "确定",
                   confirmBlock: @escaping (() -> Void) = {}) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)

        var cancelTitle = "知道了"
        if isNeedConfirm {
            cancelTitle = "取消"
            let okAction = UIAlertAction.init(title: confirmTitle, style: .default) { (_) in
                confirmBlock()
            }
            alert.addAction(okAction)
        }

        let cancelAction = UIAlertAction.init(title: cancelTitle, style: .cancel) { (_) in
            cancelBlock()
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    func showResult(text: String?) {
        let alert = UIAlertController.init(title: "确认", message: "请手动确认结果", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = text
        }

        let okAction = UIAlertAction(title: "确认", style: .default) { (action) in
            guard let textField = alert.textFields?.first, let confirmedText = textField.text else {
                return
            }

            self.scanResult?(confirmedText)
            self.backToPop()
        }

        let cancelAction = UIAlertAction(title: "重新扫描", style: .cancel) { (action) in
            self.qrScanAnimation()
            if let session = self.session, !session.isRunning {
                session.startRunning()
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension QRCodeScanVC: AVCaptureMetadataOutputObjectsDelegate {
    /// 获取二维码扫描结果
    ///
    /// - Parameters:
    ///   - output: 流输出
    ///   - metadataObjects: 元数据
    ///   - connection: 流连接
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if (metadataObjects.count == 0) {
            return
        }
        if metadataObjects.count > 0 {
            // 停止会话
            session?.stopRunning()
            // 获取扫描数据
            guard let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject, let str = metadataObject.stringValue else {
                return
            }
            // 赋值字符串
            qrCodeString = str
            showResult(text: str)
        }
    }
}

extension QRCodeScanVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - imagePickerController delegate
    /**
     *  读取选择的图片进行二维码识别
     *
     *  @param picker 图片选择控制器
     *  @param info   选择数据
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 1.获取选择的图片
        guard let srcImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let cgImage = srcImage.cgImage else {
            return
        }
        // 2.初始化一个监测器
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
            return
        }
        picker.dismiss(animated: true, completion: {
            // 监测到的结果数组
            let features = detector.features(in: CIImage(cgImage: cgImage))
            if features.count >= 1 {
                // 结果对象
                let feature = features[0] as? CIQRCodeFeature
                let scannedResult: String? = feature?.messageString
                // 赋值字符串
                self.qrCodeString = scannedResult
                self.showAlert(title: "扫描结果", message: self.qrCodeString ?? "")
            } else {
                self.showAlert(title: "提示", message: "该图片没有包含二维码！")
            }
        })
    }
}
