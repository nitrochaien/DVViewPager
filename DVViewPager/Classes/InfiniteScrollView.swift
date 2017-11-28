//
//  InfiniteScrollView.swift
//  SimpleUIKit
//
//  Created by Nam Vu on 11/17/17.
//  Copyright © 2017 hiworld. All rights reserved.
//

import UIKit
import Foundation

protocol InfiniteScrollViewDelegate {
    func didScrollToIndex(_ index: Int)
    func didSelectIndex(_ index: Int)
    func imageDownloaded()
}

open class InfiniteScrollView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    open var imageURLs: [String]!
    open var currentIndex: Int = 0
    var scrollDelegate: InfiniteScrollViewDelegate?
    
    fileprivate var onceOnly: Bool = false
    fileprivate var swipeTimer: Timer!
    fileprivate let maxPage = 512
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        let flowLayout = layout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .horizontal
        flowLayout.invalidateLayout()
        flowLayout.minimumLineSpacing = 0
        
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }

    fileprivate func initialize() {
        backgroundColor = .clear
        isPagingEnabled = true
        if #available(iOS 10.0, *) {
            isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false

        delegate = self
        dataSource = self
        
        register(InfiniteCell.self, forCellWithReuseIdentifier: "cell")

        imageURLs = [String]()
    }
    
    fileprivate func startTimer() {
        if swipeTimer == nil {
            if #available(iOS 10.0, *) {
                swipeTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: 2)!, repeats: true, block: { (time) in
                    self.next()
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    fileprivate func stopTimer() {
        if swipeTimer != nil {
            swipeTimer.invalidate()
            swipeTimer = nil
        }
    }
    
    fileprivate func next() {
        scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
        let nextIndex = IndexPath(row: currentIndex + 1, section: 0)
        scrollToItem(at: nextIndex, at: .centeredHorizontally, animated: true)
    }
    
    fileprivate func scrollToCenter(_ animate: Bool) {
        let count = imageURLs.count
        var index = currentIndex % count
        index = index + ((maxPage * count) / 2)
        currentIndex = index
        
        let indexPath = IndexPath(row: index, section: 0)
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animate)
    }
    
    //MARK: Collection View Delegate + Datasource
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !onceOnly {
            let count = imageURLs.count
            let index = currentIndex % count
            currentIndex = (maxPage * count) / 2 + index
            let indexPathToScrollTo = IndexPath(row: currentIndex, section: 0)
            collectionView.scrollToItem(at: indexPathToScrollTo, at: .centeredHorizontally, animated: false)
            onceOnly = true
            isUserInteractionEnabled = true
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if let subView = cell.viewWithTag(1) {
            let imageView = subView as! UIImageView
            let index = indexPath.row % imageURLs.count
            imageView.sd_setImage(with: URL(string: imageURLs[index]), placeholderImage: nil, options: .cacheMemoryOnly) { (image, err, type, url) in
                guard let image = image, err == nil else { return }
                
                imageView.image = image
                self.scrollDelegate?.imageDownloaded()
            }
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count * maxPage
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row % imageURLs.count
        scrollDelegate?.didSelectIndex(index)
    }
    
    //MARK: Collection View Flow Layout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let offsetX = CGFloat(currentIndex) * bounds.width
        return CGPoint(x: offsetX, y: 0)
    }
    
    //MARK: ScrollView Delegate
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //User scroll
        updateScrolling(scrollView)
        startTimer()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //Auto scroll
        updateScrolling(scrollView)
    }
    
    fileprivate func updateScrolling(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = scrollView.contentOffset.x / pageWidth

        if currentIndex != Int(currentPage) && currentPage != 0 {
            currentIndex = Int(currentPage)

            let count = imageURLs.count
            let leftMax = count + 1
            let rightMin = count * (maxPage - 2)
            if currentIndex < leftMax || currentIndex > rightMin {
                self.scrollToCenter(false)
            }

            scrollDelegate?.didScrollToIndex(currentIndex)

            scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    //MARK: public functions
    open func setData(_ list: [String]) {
        imageURLs = [String]()
        
        DispatchQueue.main.async {
            self.reloadData()
            self.imageURLs = list
            
            self.onceOnly = false
            self.performBatchUpdates({}, completion: { (finished) in
                self.startTimer()
            })
        }
    }
    
    open func startAnimating() {
        startTimer()
    }
    
    open func stopAnimating() {
        stopTimer()
    }
}

class InfiniteCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    fileprivate func initialize() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imageView.tag = 1
        imageView.contentMode = .scaleToFill
        
        addSubview(imageView)
    }
}
