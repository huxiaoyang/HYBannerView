//
//  ViewController.swift
//  BSBannerView
//
//  Created by ucredit-XiaoYang on 2016/10/10.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let imageUrlList: [Any] = [
        "http://g.hiphotos.baidu.com/zhidao/pic/item/e4dde71190ef76c651305dae9f16fdfaae516751.jpg",
        "http://imgsrc.baidu.com/forum/w=580/sign=d8ed32237b1ed21b79c92eed9d6fddae/2af6314e251f95ca8eb13167cf177f3e65095293.jpg",
        "http://b.hiphotos.baidu.com/zhidao/pic/item/e7cd7b899e510fb3bebd6de4df33c895d1430c18.jpg",
        "http://a.hiphotos.baidu.com/zhidao/pic/item/d0c8a786c9177f3ec7b6d24f71cf3bc79e3d56f5.jpg",
        localImage
    ]
    
    var autoScrollView: BannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = false
        self.edgesForExtendedLayout = UIRectEdge()

        
        self.view.backgroundColor = UIColor.green
        
        let width = view.bounds.width
        let height = view.bounds.height
        
        //ScrollView 实现，无限轮播
        autoScrollView = BannerView(frame: CGRect(x: 0, y: 0, width: width, height: height/3))
        autoScrollView.backgroundColor = UIColor.red
        autoScrollView.rollingTime = 5.0
        autoScrollView.images = imageUrlList
        autoScrollView.delegate = self
        view.addSubview(autoScrollView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
        
        autoScrollView.rollingEnable = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        autoScrollView.rollingEnable = true
    }


}



extension ViewController: BannerViewDelegate {
    
    func bannerViewDidTapped(index: Int) {
        print("clicked index is: \(index)")
    }
    
    
    
}

