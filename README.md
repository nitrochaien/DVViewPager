# DVViewPager

[![Version](https://img.shields.io/cocoapods/v/DVViewPager.svg?style=flat)](http://cocoapods.org/pods/DVViewPager)
[![License](https://img.shields.io/cocoapods/l/DVViewPager.svg?style=flat)](http://cocoapods.org/pods/DVViewPager)
[![Platform](https://img.shields.io/cocoapods/p/DVViewPager.svg?style=flat)](http://cocoapods.org/pods/DVViewPager)

## Introduction
- Android's ViewPager implemented in Swift 4
- Load images from URLs (using [SDWebImage](https://github.com/rs/SDWebImage))

## Requirements
- Xcode 9+
- iOS 10+

## Installation

DVViewPager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DVViewPager'
```

## How to use
```
let width = UIScreen.main.bounds.width
let height = width * 9 / 16

let infiniteScrollView = InfiniteScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height), collectionViewLayout: UICollectionViewFlowLayout())
infiniteScrollView.backgroundColor = .green
infiniteScrollView.setData(myList)

view.addSubview(infiniteScrollView)
```

## Note
`width` property must be Srceen Width

## Author
vunam0502@gmail.com

## License
DVViewPager is available under the MIT license. See the LICENSE file for more info.
