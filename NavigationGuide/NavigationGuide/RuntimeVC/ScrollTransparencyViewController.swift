//
//  ScrollTransparencyViewController.swift
//  NavigationGuide
//
//  Created by deer on 2018/7/18.
//  Copyright © 2018年 deer. All rights reserved.
//

import UIKit

class ScrollTransparencyViewController: UIViewController {

    var isStatusBarLight = true
    var tableView: UITableView!
    lazy var headView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
        view.backgroundColor = .blue
        return view
    }()
    lazy var tableHeadView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initTableView()
        self.navBarAlpha = 0
        self.navBarTintColor = .white

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    func initTableView() {
        tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.frame = view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "testCell")
        view.addSubview(tableView)
        tableView.tableHeaderView = tableHeadView
        tableView.addSubview(headView)

        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0

        tableView.dataSource = self
        tableView.delegate = self
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isStatusBarLight ? .lightContent : .default
    }
}


extension ScrollTransparencyViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 66
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)行"
        return cell
    }

}

extension ScrollTransparencyViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK:UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView)
        let offsetY = scrollView.contentOffset.y
        let barHeight = UIApplication.shared.statusBarFrame.height + 44
        if offsetY > (200 - barHeight) {
            // 显示背景
            let newAlpha = (offsetY - (200 - barHeight)) / barHeight
            navBarAlpha = newAlpha
            if newAlpha > 0.8 {
                navBarTintColor = .blue
                isStatusBarLight = false
//                navigationController?.navigationBar.barStyle = .black
            } else {
                navBarTintColor = .white
                isStatusBarLight = true
            }
        } else {
            navBarAlpha = 0
            navBarTintColor = .white
            isStatusBarLight = true
//            navigationController?.navigationBar.barStyle = .default
        }
        setNeedsStatusBarAppearanceUpdate()
        adjustHeadView(offsetY)
    }

    func adjustHeadView(_ offsetY: CGFloat) {

        if offsetY <= 0 {
//            headView.transform = CGAffineTransform(translationX: 0, y: offsetY)
            var frame = headView.frame
            frame.origin.y = offsetY
            frame.size.height = 200 - offsetY
            headView.frame = frame
        } else {
            var frame = headView.frame
            frame.size.height = 200
            headView.frame = frame
        }
        debugPrint(headView.frame)
    }
}
