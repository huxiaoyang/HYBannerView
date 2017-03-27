//
//  BannerView.swift
//  BSBannerView
//
//  Created by ucredit-XiaoYang on 2016/10/10.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

import Foundation
import UIKit


protocol BannerViewDelegate: NSObjectProtocol {
    func bannerViewDidTapped(index: Int)
}


class BannerView: UIView {
    
    fileprivate var currentPage: Int = 0 {
        didSet {
            loadImages()
            pageControl.currentPage = currentPage
        }
    }
    
    public var images = [Any]() {
        didSet {
            setupImageViews()
            self.rollingEnable = true
        }
    }
    
    private var imageCount: Int {
        return images.count
    }
    
    
//MARK: - 懒加载
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = self.bounds
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        return scrollView
    }()
    
    public lazy var pageControl: UIPageControl = {
        let width = self.bounds.width/5
        let height = 15 as CGFloat
        let x = (self.bounds.width - width)/2
        let y = self.bounds.height - height * 2
        let pageControl = UIPageControl(frame: CGRect(x: x, y: y, width: width, height: height))
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    private lazy var imageViewList: [UIImageView] = {
        var imageViewList = [UIImageView]()
        let counts = self.imageCount
        if counts == 1 {
            let imageView = UIImageView(image: localImage)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageViewList.append(imageView)
        } else if counts > 1 {
            for i in 0 ..< 3 {
                let imageView = UIImageView(image: localImage)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageViewList.append(imageView)
            }
        }
        return imageViewList
    }()
    
    
    fileprivate var width: CGFloat!
    fileprivate var height: CGFloat!
    
    
//MARK: 协议
    weak var delegate: BannerViewDelegate?
    
//MARK: 计时器
    private var timer: Timer?
    public var rollingTime: TimeInterval = 3.0
    var rollingEnable: Bool = false {
        willSet {
            guard imageCount > 1 else {
                return
            }
            if newValue {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
    
    
//MARK: initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        width = frame.width
        height = frame.height
        
        addSubview(scrollView)
        addSubview(pageControl)
        
        addBannerGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Banner is released.")
    }
    
    
//MARK: UI加载
    private func setupImageViews() {
        pageControl.numberOfPages = imageCount
        pageControl.currentPage = 0
        currentPage = 0
        
        scrollView.contentSize = CGSize(width: width * CGFloat(imageViewList.count), height: height)
        let imageViewCount = imageViewList.count
        for i in 0 ..< imageViewCount {
            let imageView = imageViewList[i]
            imageView.frame = CGRect(x: width * CGFloat(i), y: 0, width: width, height: height)
            scrollView.addSubview(imageView)
        }
        
        if imageCount == 1 {
            scrollView.contentOffset.x = 0
        } else if imageCount > 1 {
            scrollView.contentOffset.x = width
        }
        
    }
    
    private func loadImages() {
        if imageCount == 1 {
            
            loadImageFrom(images[0], flag: 0, completion: { image, flag in
                self.imageViewList[0].image = image
            })
            
        } else if imageCount > 1 {
            
            switch currentPage {
            case 0:
                loadImageFrom(images[imageCount - 1], flag: imageCount - 1, completion: { image, flag in
                    self.imageViewList[0].image = image
                })
                loadImageFrom(images[currentPage], flag: currentPage, completion: { image, flag in
                    self.imageViewList[1].image = image
                })
                loadImageFrom(images[currentPage + 1], flag: currentPage + 1, completion: { image, flag in
                    self.imageViewList[2].image = image
                })
            case imageCount - 1:
                loadImageFrom(images[currentPage-1], flag: currentPage - 1, completion: { image, flag in
                    self.imageViewList[0].image = image
                })
                loadImageFrom(images[currentPage], flag: currentPage, completion: { image, flag in
                    self.imageViewList[1].image = image
                })
                loadImageFrom(images[0], flag: 0, completion: { image, flag in
                    self.imageViewList[2].image = image
                })
            default:
                loadImageFrom(images[currentPage - 1], flag: currentPage - 1, completion: { image, flag in
                    self.imageViewList[0].image = image
                })
                loadImageFrom(images[currentPage], flag: currentPage, completion: { image, flag in
                    self.imageViewList[1].image = image
                })
                loadImageFrom(images[currentPage + 1], flag: currentPage + 1, completion: { image, flag in
                    self.imageViewList[2].image = image
                })
            }
            
        }
        
        scrollView.contentOffset = CGPoint(x: width, y: 0)
        
    }
    
//MARK: 点击事件
    private func addBannerGesture() {
        let tap = UITapGestureRecognizer(target:self, action: #selector(tapAction))
        self.scrollView.addGestureRecognizer(tap)
    }
    
    func tapAction() {
        delegate?.bannerViewDidTapped(index: currentPage)
    }
    
//MARK: 定时器
    fileprivate func startTimer() {
        DispatchQueue.global().async {
            self.timer = Timer.scheduledTimer(timeInterval: self.rollingTime, target: self, selector: #selector(self.nextPage), userInfo: nil, repeats: true)
            RunLoop.current.run()
        }
    }
    
    fileprivate func stopTimer() {
        timer!.invalidate()
        timer = nil
    }
    
    func nextPage() {
        scrollView.setContentOffset(CGPoint(x: width * 2, y: 0), animated: true)
    }

}


extension BannerView: UIScrollViewDelegate {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        currentPage = (currentPage+1)%images.count
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.isScrollEnabled = true

        if scrollView.contentOffset.x == 0 {                    //向前滑动
            if currentPage == 0 {
                currentPage = images.count-1
            } else {
                currentPage -= 1
            }
        } else if scrollView.contentOffset.x == 2 * width {     //向后滑动
            currentPage = (currentPage+1)%images.count
        }
    }
    
    //拖动scrollView时会停止自动滚动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if rollingEnable {
            stopTimer()
        }
    }
    //停止拖动后会重新开始自动滚动
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if rollingEnable {
            startTimer()
        }
        //在滚动的减速动画没有结束前继续拖动时,因为还没有更新所以边缘是空白,所以在结束拖动时就锁住scrollView,在动画结束后解锁,就可以避免这个问题
        scrollView.isScrollEnabled = false
    }
    
    
}





