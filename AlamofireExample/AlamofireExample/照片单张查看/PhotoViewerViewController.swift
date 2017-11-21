//
//  PhotoViewerViewController.swift
//  Photomania
//
//  Created by Essan Parto on 2014-08-24.
//  Copyright (c) 2014 Essan Parto. All rights reserved.
//

import UIKit
import QuartzCore
import Alamofire

fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class PhotoViewerViewController: UIViewController {
    var photoID = 0
    
    fileprivate let scrollView = UIScrollView()
    fileprivate let imageView = UIImageView()
    fileprivate let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var photoInfo: PhotoInfo?
    
    // MARK: Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        loadPhoto()
    }
    
    private func loadPhoto() {
        Alamofire.request(Five100px.Router.photoInfo(photoID, .large)).validate().responseObject {
            (response: DataResponse<PhotoInfo>) in
            
            guard let info = response.result.value else { return }
            
            self.photoInfo = info
            
            DispatchQueue.main.async {
                self.addButtomBar()
                self.title = info.url
            }
            
            /*
            在请求响应对象之前调用的 .validate() 函数是另一个易用的 Alamofire 特性。将其与请求和响应链接，以确认响应的状态码在默认可接受的范围（200到299）内。如果认证失败，响应处理方法将出现一个相关错误，您可以在完成处理方法中处理这个错误。
            
            即使没有发生错误，完成处理方法仍然还是会被调用。
            */
            Alamofire.request(info.url, method: .get).validate().responseImage {
                response in
                guard let image = response.result.value else { return }
                
                self.imageView.image = image
                self.imageView.frame = self.centerFrameFromImage(image)
                
                self.spinner.stopAnimating()
                self.centerScrollViewContents()
            }
        }
    }
    
    func setupView() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        spinner.center = CGPoint(x: view.center.x, y: view.center.y - view.bounds.origin.y / 2.0)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        view.addSubview(spinner)
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        view.addSubview(scrollView)
        
        imageView.contentMode = .scaleAspectFill
        scrollView.addSubview(imageView)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.numberOfTouchesRequired = 1
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
        scrollView.addGestureRecognizer(singleTapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if photoInfo != nil {
            navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    // MARK: Bottom Bar
    
    private func addButtomBar() {
        var items = [UIBarButtonItem]()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        items.append(barButtonItemWithImageNamed("hamburger", title: nil, action: #selector(showDetails)))
        
        if photoInfo?.commentsCount > 0 {
            items.append(barButtonItemWithImageNamed("bubble", title: "\(photoInfo?.commentsCount ?? 0)", action: #selector(showComments)))
        }
        
        items.append(flexibleSpace)
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(showActions)))
        items.append(flexibleSpace)
        
        items.append(barButtonItemWithImageNamed("like", title: "\(photoInfo?.votesCount ?? 0)"))
        items.append(barButtonItemWithImageNamed("heart", title: "\(photoInfo?.favoritesCount ?? 0)"))
        
        self.setToolbarItems(items, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userInfoViewForPhotoInfo(photoInfo!))
    }
    
    private func userInfoViewForPhotoInfo(_ photoInfo: PhotoInfo) -> UIView {
        let userProfileImageView = UIImageView(frame: CGRect(x: 0, y: 10.0, width: 30.0, height: 30.0))
        userProfileImageView.layer.cornerRadius = 3.0
        userProfileImageView.layer.masksToBounds = true
        
        return userProfileImageView
    }
    
    @objc private dynamic func showDetails() {
        guard let photoDetailsViewController = storyboard?.instantiateViewController(withIdentifier: "PhotoDetails") as? PhotoDetailsViewController else { return }
        photoDetailsViewController.modalPresentationStyle = .overCurrentContext
        photoDetailsViewController.modalTransitionStyle = .coverVertical
        photoDetailsViewController.photoInfo = photoInfo
        
        present(photoDetailsViewController, animated: true, completion: nil)
    }
    
    @objc private dynamic func showComments() {
        guard let photoCommentsViewController = storyboard?.instantiateViewController(withIdentifier: "PhotoComments") as? PhotoCommentsViewController else { return }
        photoCommentsViewController.modalPresentationStyle = .popover
        photoCommentsViewController.modalTransitionStyle = .coverVertical
        photoCommentsViewController.photoID = photoID
        photoCommentsViewController.popoverPresentationController?.delegate = self
        present(photoCommentsViewController, animated: true, completion: nil)
    }
    
    private func barButtonItemWithImageNamed(_ imageName: String?, title: String?, action: Selector? = nil) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        
        if let imageName = imageName {
            button.setImage(UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        }
        
        if let title = title {
            button.setTitle(title, for: UIControlState())
            button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
            
            let font = UIFont.preferredFont(forTextStyle: .footnote)
            button.titleLabel?.font = font
        }
        
        let size = button.sizeThatFits(CGSize(width: 90.0, height: 30.0))
        button.frame.size = CGSize(width: min(size.width + 10.0, 60), height: size.height)
        
        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        
        let barButton = UIBarButtonItem(customView: button)
        
        return barButton
    }
    
    // MARK: Download Photo
    
    @objc private dynamic func showActions() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Download Photos", style: .default, handler: {
            action in
            self.downloadPhoto()
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func downloadPhoto() {
        // 下载图片
        Alamofire.request(Five100px.Router.photoInfo(photoInfo!.id, .xLarge)).validate().responseJSON {
            response in
            guard let jsonDictionary = response.result.value as? [String: Any],
                let imageURL = (jsonDictionary as AnyObject).value(forKeyPath: "photo.image_url") as? String else { return }
            
            // 存储到本地的路径
//            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)
            
            // 维持文件名的唯一性
            let destination: DownloadRequest.DownloadFileDestination = { _, response in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("\(self.photoInfo!.id).\(String(describing: response.suggestedFilename))")
                
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            // 不需要响应方法，不需要响应序列化方法处理数据
            let progressIndicatorView = UIProgressView(frame: CGRect(x: 0.0, y: 80.0, width: self.view.bounds.width, height: 10.0))
            progressIndicatorView.tintColor = .blue
            self.view.addSubview(progressIndicatorView)
            
            let _ = Alamofire.download(imageURL, to: destination).downloadProgress { progress in
                DispatchQueue.main.async {
                    progressIndicatorView.setProgress(Float(progress.fractionCompleted), animated: true)
                    if progress.fractionCompleted == 1 {
                        progressIndicatorView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    // MARK: Gesture Recognizers
    
    @objc private dynamic func handleDoubleTap(_ recognizer: UITapGestureRecognizer!) {
        let pointInView = recognizer.location(in: imageView)
        zoomInZoomOut(pointInView)
    }
    
    @objc private dynamic func handleSingleTap(_ recognizer: UITapGestureRecognizer!) {
        let hidden = navigationController?.navigationBar.isHidden ?? false
        navigationController?.setNavigationBarHidden(!hidden, animated: true)
        navigationController?.setToolbarHidden(!hidden, animated: true)
    }
    
    private func zoomInZoomOut(_ point: CGPoint!) {
        let newZoomScale = scrollView.zoomScale > (scrollView.maximumZoomScale/2) ? scrollView.minimumZoomScale : scrollView.maximumZoomScale
        
        let scrollViewSize = scrollView.bounds.size
        
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let x = point.x - (width / 2.0)
        let y = point.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: x, y: y, width: width, height: height)
        
        self.scrollView.zoom(to: rectToZoom, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return !(navigationController?.navigationBar.isHidden ?? false)
    }
}

// MARK: ScrollView

extension PhotoViewerViewController: UIScrollViewDelegate {
    
    fileprivate func centerFrameFromImage(_ image: UIImage?) -> CGRect {
        
        guard let image = image else { return CGRect() }
        
        let scaleFactor = scrollView.frame.width / image.size.width
        let newHeight = image.size.height * scaleFactor
        
        var newImageSize = CGSize(width: scrollView.frame.width, height: newHeight)
        
        newImageSize.height = min(scrollView.frame.height, newImageSize.height)
        
        let centerFrame = CGRect(x: 0.0, y: scrollView.frame.height/2 - newImageSize.height/2, width: newImageSize.width, height: newImageSize.height)
        
        return centerFrame
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    fileprivate func centerScrollViewContents() {
        let boundsSize = scrollView.frame
        var contentsFrame = imageView.frame
        
        if contentsFrame.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - scrollView.scrollIndicatorInsets.top - scrollView.scrollIndicatorInsets.bottom - contentsFrame.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        self.imageView.frame = contentsFrame
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}

extension PhotoViewerViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overCurrentContext
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        
        return navController
    }
}
