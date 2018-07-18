# AdvertisementView 广告页组件
## 介绍
App启动广告页，支持播放Gif/png/jpg等。（组件中已经监听了app的 UIApplicationDidFinishLaunching 通知，通知来了会把广告页添加到keyWindow中，使用者只需要创建即可。）


> Swift 4.2
> iOS 8.0
> Xcode 10.0
> 

### 思路
**支持播放本地与网络Gif和图片资源。如果是网络资源先下载到本地，根据资源路径命名缓存。Gif的播放使用DispatchSource创建定时器+ ImageIO框架获取帧图片。**

### **版本迭代**
- 2.1.0
    -  升级到Swift 4.2
- 2.0.2
    -  修复显示广告页之前，闪现首页界面的问题
- 2.0.1
    -  添加在广告页未加载完之前显示的占位图参数：placeholderImage，默认显示启动图

## 可配置接口介绍

### 1.实例化接口及可配置参数

```Swift
/// App启动广告页
///
/// - Parameters:
///   - frame: 广告页大小，default: UIScreen.main.bounds
///   - duration: 广告页显示时间，default: 3秒
///   - delay: 广告页展示完成后的停留时间，default: 1.0秒
///   - adUrl: 广告资源路径（本地或网络链接,使用时只传入URL即可）
///   - isHiddenSkipBtn: 是否隐藏跳过按钮(true 隐藏; false 不隐藏)，default: false
///   - isIgnoreCache: 是否忽略本地缓存(true 忽略; false 缓存)，default: true
///   - placeholderImage: 在广告页未加载完之前显示的占位图，默认显示启动图
///   - completion: 用户点击广告事件的或公告展示完成的回调， isGotoDetailView 为ture表示点击了公告详情
convenience public init(frame: CGRect = default, duration: Int = default, delay: Double = default, adUrl: String, isHiddenSkipBtn: Bool = default, isIgnoreCache: Bool = default, placeholderImage: UIImage?, completion: @escaping (_ isGotoDetailView: Bool) -> ())
```

### 2.如果选择本地缓存网络资源，本地缓存清理接口

```Swift
/// 删除本地缓存的广告资源
///
/// - Parameter url: 资源路径
/// - Returns: 返回ture表示删除成功，false删除失败
public class func clearAdDataFromLocal(_ url: String) -> Bool

/// 删除本地所有缓存
///
/// - Returns: 返回ture表示删除成功，false删除失败
public class func clealAllLocalCache() -> Bool
```

## Example

### 配置Podfile

```Swift
pod 'AdvertisementView'
```

### 执行pod命令，导入组件

```Swift
pod install
```
### 案例

```Swift
// 网络资源
let adImageJPGUrl = "http://p5.image.hiapk.com/uploads/allimg/150112/7730-150112143S3.jpg"
let adimageGIFUrl = "http://img.ui.cn/data/file/3/4/6/210643.gif"
// 本地资源
let adImageJPGPath = Bundle.main.path(forResource: "adImage2", ofType: "jpg") ?? ""
let adImageGifPath = Bundle.main.path(forResource: "adImage3", ofType: "gif") ?? ""

let _ = AdvertisementView(adUrl: adImageGifPath, isIgnoreCache: false, placeholderImage: nil, completion: { (isGotoDetailView) in
    print(isGotoDetailView)
})
```

###二、GIF演示

#### 播放GiF资源

![播放Gif资源](http://upload-images.jianshu.io/upload_images/877439-622f6ac4decbc009.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


#### 播放图片资源

![播放图片资源](http://upload-images.jianshu.io/upload_images/877439-39885f0571c6e3b7.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
