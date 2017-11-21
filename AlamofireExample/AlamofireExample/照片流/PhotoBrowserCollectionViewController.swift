//
//  PhotoBrowserCollectionViewController.swift
//  Photomania
//
//  Created by Essan Parto on 2014-08-20.
//  Copyright (c) 2014 Essan Parto. All rights reserved.
//

import UIKit
import Alamofire

class PhotoBrowserCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var photos = Set<PhotoInfo>()
    
    private let imageCache = NSCache<NSString, UIImage>()
    private let refreshControl = UIRefreshControl()
    // 是否更新照片
    private var populatingPhotos = false
    // 当前浏览哪个页面
    private var currentPage = 1
    
    private let PhotoBrowserCellIdentifier = "PhotoBrowserCell"
    private let PhotoBrowserFooterViewIdentifier = "PhotoBrowserFooterView"
    
    // MARK: Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        populatePhotos()
    }
    
    private func populatePhotos() {
        if populatingPhotos {
            return
        }
        
        populatingPhotos = true
        Alamofire.request(Five100px.Router.popularPhotos(currentPage)).responseJSON { (response) in
            guard let Json = response.result.value, response.result.error == nil else {
                self.populatingPhotos = false
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                guard let photosJson = (Json as AnyObject).value(forKey: "photos") as? [[String: Any]] else {
                    return
                }
                let lastItemCount = self.photos.count
                
                photosJson.forEach {
                    guard let nsfw = $0["nsfw"] as? Bool, let id = $0["id"] as? Int, let url = $0["image_url"] as? String, nsfw == false else {
                        return
                    }
                    self.photos.insert(PhotoInfo.init(id: id, url: url))
                }
                
                let indexPaths = (lastItemCount..<self.photos.count).map {
                    IndexPath(item: $0, section: 0)
                }
                DispatchQueue.main.async {
                    self.collectionView?.insertItems(at: indexPaths)
                }
                self.currentPage += 1
            }
            self.populatingPhotos = false
        }
    }
    
    /// 滚动加载判断
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.height > scrollView.contentSize.height * 0.8 {
            populatePhotos()
        }
    }
    
    // MARK: CollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoBrowserCellIdentifier, for: indexPath) as? PhotoBrowserCollectionViewCell else { return UICollectionViewCell() }
        let imageUrl = photos[photos.index(photos.startIndex, offsetBy: indexPath.item)].url
        cell.request?.cancel()
        cell.imageView.image = nil
        
        if let image = imageCache.object(forKey: imageUrl as NSString) {
            cell.imageView.image = image
            print("+++缓存加载")
        } else {
            // cell复用时，去除正在显示的图片、取消请求；准备重新请求，显示新的图片
            cell.imageView.image = nil
            cell.request = Alamofire.request(imageUrl, method: .get).responseImage { (response) in
                guard let image = response.result.value, response.result.error == nil else {
                    return
                }
                self.imageCache.setObject(image, forKey: response.request!.url!.absoluteString as NSString)
                cell.imageView.image = image
                print("---网络加载")
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PhotoBrowserFooterViewIdentifier, for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPhoto", sender: photos[photos.index(photos.startIndex, offsetBy: indexPath.item)].id)
    }
    
    // MARK: Helper
    
    private func setupView() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        guard let collectionView = collectionView else { return }
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (view.bounds.width - 2) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 100)
        
        collectionView.collectionViewLayout = layout
        
        let titleLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 60.0, height: 30.0))
        titleLabel.text = "Photomania"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        navigationItem.titleView = titleLabel
        
        collectionView.register(PhotoBrowserCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoBrowserCellIdentifier)
        collectionView.register(PhotoBrowserCollectionViewLoadingCell.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PhotoBrowserFooterViewIdentifier)
        
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PhotoViewerViewController, let id = sender as? Int, segue.identifier == "ShowPhoto" {
            destination.photoID = id
            destination.hidesBottomBarWhenPushed = true
        }
    }
    
    @objc private dynamic func handleRefresh() {
        refreshControl.beginRefreshing()
        
        photos.removeAll()
        currentPage = 1
        
        collectionView?.reloadData()
        refreshControl.endRefreshing()
        
        populatePhotos()
    }
}

class PhotoBrowserCollectionViewCell: UICollectionViewCell {
    fileprivate let imageView = UIImageView()
    fileprivate var request: Request?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        imageView.frame = bounds
        addSubview(imageView)
    }
}

class PhotoBrowserCollectionViewLoadingCell: UICollectionReusableView {
    fileprivate let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        spinner.startAnimating()
        spinner.center = center
        addSubview(spinner)
    }
}
