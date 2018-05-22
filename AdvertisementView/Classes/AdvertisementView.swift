//
//  AdvertisementView.swift
//  AdvertisementView
//
//  Created by lisilong on 2018/1/2.
//  Copyright © 2018年 tuandai. All rights reserved.
//

import UIKit

public class AdvertisementView: UIView {
    private var adFrame: CGRect = UIScreen.main.bounds  // 广告页显示大小
    private var duration: Int = 3                       // 广告页显示时间，default: 3秒
    private var adImageUrl: String?                     // 广告页资源链接
    private var isHiddenSkipBtn: Bool = false           // 是否隐藏跳过按钮(true 隐藏; false 不隐藏)，default: false
    private var delayAfterTimeOut: Double = 1.0         // 广告页展示完成后的停留时间，default: 1.0秒
    private var isIgnoreCache: Bool = true              // 是否忽略本地缓存，每次都从网络下载(true 忽略; false 要缓存)，default: true
    private var placeholderImage: UIImage?              // 在广告页未加载完之前显示的占位图

    private lazy var launchImageView: UIImageView = {   // APP启动图片（作用：让在加载广告页时，有个平滑的过度阶段）
        let view = UIImageView.init(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.white
        return view
    }()
    private lazy var adImageView: UIImageView = {       // APP广告图片
        let adImageView = UIImageView.init(frame: UIScreen.main.bounds)
        adImageView.isUserInteractionEnabled = true
        adImageView.alpha = 0
        adImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didClickAdView)))
        return adImageView
    }()
    private lazy var skipButton: UIButton = {           // 跳过按钮
        let btn = UIButton.init(type: .custom)
        btn.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        btn.layer.cornerRadius = 5.0
        btn.layer.masksToBounds = true
        btn.setTitle("跳过广告", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.titleLabel?.textColor = UIColor.white
        btn.titleLabel?.sizeToFit()
        btn.isHidden = true
        btn.addTarget(self, action: #selector(skipBtnClicked), for: .touchUpInside)
        return btn
    }()
    private var skipBtnTimer: DispatchSourceTimer?      // 跳过广告按钮定时器
    private var gifView: GifImageOperation?             // 播放gif视图
    private var completion: ((_ isGotoDetailView: Bool) -> ())?     // 用户点击广告图片的回调

    // MARK: - life cycle
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

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
    convenience public init(frame: CGRect = UIScreen.main.bounds,
                     duration: Int = 3,
                     delay: Double = 1.0,
                     adUrl: String,
                     isHiddenSkipBtn: Bool = false,
                     isIgnoreCache: Bool = true,
                     placeholderImage: UIImage?,
                     completion: @escaping (_ isGotoDetailView: Bool) -> ()) {
        self.init(frame: frame)
        self.adFrame = frame
        self.duration = duration
        self.delayAfterTimeOut = delay
        self.adImageUrl = adUrl
        self.isHiddenSkipBtn = isHiddenSkipBtn
        self.isIgnoreCache = isIgnoreCache
        self.placeholderImage = placeholderImage
        self.completion = completion
        
        self.setupSubviews()
        self.loadDataSource()
        self.startShowAdImageView()
        self.addLaunchAdViewToWindow()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup
    private func setupSubviews() {
        launchImageView.image = (placeholderImage != nil) ? placeholderImage : loadLaunchImage()
        self.addSubview(launchImageView)

        adImageView.frame = self.adFrame
        self.addSubview(adImageView)

        skipButton.frame = CGRect.init(x: UIScreen.main.bounds.size.width - 80.0 , y: 30.0, width: 70.0, height: 26.0)
        let adDuration = self.duration > 0 ? self.duration : 3
        skipButton.setTitle("跳过广告\(adDuration)", for: .normal)
        self.addSubview(skipButton)

        // "跳过广告"按钮定时器
        skipBtnTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        skipBtnTimer?.schedule(deadline: .now(), repeating: 1.0)
        self.duration = self.duration > 0 ? self.duration : 3
        skipBtnTimer?.setEventHandler(handler: { [weak self] in
            DispatchQueue.main.async {
                let title = "跳过广告\(self?.duration ?? 0)"
                let strTitle: NSMutableAttributedString = NSMutableAttributedString.init(string: title)
                strTitle.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 14), range: NSRange.init(location: 4, length: title.count - 4))
                self?.skipButton.setAttributedTitle(strTitle, for: .normal)
                self?.duration -= 1
                if self?.duration ?? 0 < 0 {
                    self?.skipBtnTimer?.cancel()
                }
            }
        })
    }

    // MARK: - load dataSource
    /// 加载资源并展示
    private func loadDataSource() {
        guard let adUrl = self.adImageUrl else {
            return
        }
        var data: Data?
        if self.checkUrlIsNetWorkData(urlString: adUrl) {   // 网络资源
            data = self.getAdData(url: adUrl)
        } else {                                            // 本地资源
            data = try? NSData.init(contentsOfFile: adUrl) as Data
        }
        guard let imageData = data else { return }
        let type = GifImageOperation.checkDataType(data: imageData)
        if type == .gif {
            gifView = GifImageOperation.init(frame: adImageView.frame, gifData: imageData)
            adImageView.addSubview(gifView!)
        } else {
            adImageView.image = UIImage.init(data: imageData)
        }
    }

    /// 从网络下载或本地缓存中获取广告资源
    ///
    /// - Parameter url: 广告资源路径
    /// - Returns: 广告资源
    private func getAdData(url: String) -> Data? {
        if isIgnoreCache {  // 忽略缓存
            return try? Data.init(contentsOf: URL.init(string: url)!)
        } else {            // 先从本地缓存中获取，获取不到网络下载
            var adData: Data? = AdvertisementView.getAdDataFromLocal(url)
            if adData == nil {
                // 当缓存超过5个的时候，清空缓存
                if let filePath = AdvertisementView.rootFilePath() {
                    if FileManager.default.subpaths(atPath: filePath)?.count ?? 0 > 5 {
                        let _ = AdvertisementView.clealAllLocalCache()
                    }
                }
                // 下载并缓存
                adData = try? Data.init(contentsOf: URL.init(string: url)!)
                let _ = AdvertisementView.saveDataToLocal(url, data: adData)
            }
            return adData
        }
    }
    
    /// 获取项目中的App启动页图片
    ///
    /// - Returns: 返回启动页图片
    private func loadLaunchImage() -> UIImage? {
        let viewSize    = UIScreen.main.bounds.size
        let orientation = UIApplication.shared.statusBarOrientation
        let viewOrientation = (orientation == .landscapeLeft || orientation == .landscapeRight) ? "Landscape" : "Portrait"
        var imageName: UIImage? = nil
        let imagesInfoArray = Bundle.main.infoDictionary!["UILaunchImages"]
        guard imagesInfoArray != nil else {
            return nil
        }
        for dict: Dictionary <String, String> in imagesInfoArray as! Array {
            let imageSize = CGSizeFromString(dict["UILaunchImageSize"]!)
            if imageSize.equalTo(viewSize) && viewOrientation == dict["UILaunchImageOrientation"]! as String {
                imageName = UIImage(named: dict["UILaunchImageName"]!)
            }
        }
        return imageName
    }
    
    // MARK: - actions
    
    /// 验证url资源是网络还是本地资源
    ///
    /// - Parameter urlString: 资源路径
    /// - Returns: 返回 true 表示为网络资源，false 为本地资源
    private func checkUrlIsNetWorkData(urlString: String?) -> Bool {
        guard urlString != nil else { return false }
        let regex = "http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?"
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with:urlString)
    }

    /// 柔滑的展示广告页，并开始动画
    private func startShowAdImageView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            UIView.animate(withDuration: 0.5, animations: {
                self.adImageView.alpha = 1.0
            }) { (_) in
                self.skipButton.isHidden = self.isHiddenSkipBtn
                self.skipBtnTimer?.resume()
                self.gifView?.startAnimation()
                self.endShowAdImageView()
            }
        }
    }

    /// 如果没有点击“跳过广告”按钮，会在展示完后，柔滑的退出
    private func endShowAdImageView() {
        let adDuration: Int = self.duration > 0 ? self.duration : 3
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(adDuration)) {
            self.removeLaunchAdViewFromSuperview(delay: self.delayAfterTimeOut)
            if self.completion != nil {
                self.completion!(false)
            }
        }
    }

    /// 从App中移除广告页
    ///
    /// - Parameter delay: 界面停留时间
    private func removeLaunchAdViewFromSuperview(delay: Double) {
        UIView.animate(withDuration: 0.5, delay: delay, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            self.alpha = 0.0
        }) { (_) in
            self.skipBtnTimer?.cancel()
            self.gifView?.cancelAnimation()
            self.removeFromSuperview()
            NotificationCenter.default.removeObserver(self, name: .UIApplicationDidFinishLaunching, object: nil)
        }
    }

    /// 点击“跳过广告”按钮事件，立即退出广告页
    @objc private func skipBtnClicked() {
        removeLaunchAdViewFromSuperview(delay: 0.0)
        if self.completion != nil {
            self.completion!(false)
        }
    }

    /// 点击广告页事件
    @objc private func didClickAdView() {
        removeLaunchAdViewFromSuperview(delay: 0.0)
        if self.completion != nil {
            self.completion!(true)
        }
    }

    // MARK: - 当App启动完成后，添加到主window中显示
    /// 当接收到 UIApplicationDidFinishLaunching 通知后，添加到 keyWindow 上
    private func addLaunchAdViewToWindow() {
        NotificationCenter.default.addObserver(forName: .UIApplicationDidFinishLaunching, object: nil, queue: nil) { [weak self] (_) in
            DispatchQueue.main.async {
                guard self != nil else { return }
                UIApplication.shared.keyWindow?.addSubview(self!)
            }
        }
    }
}

// MARK: - 本地缓存文件操作
extension AdvertisementView {
    /// 保存下载好的资源到本地沙盒
    ///
    /// - Parameters:
    ///   - url: 资源路径
    ///   - data: 广告资源
    /// - Returns: 返回ture表示保存成功，false保存失败
    class func saveDataToLocal(_ url: String, data: Data?) -> Bool {
        guard data != nil, let filePath = self.filePath(url) else {
            return false
        }
        let isSuccess = NSKeyedArchiver.archiveRootObject(data!, toFile: filePath)
        return isSuccess
    }
    
    /// 获取本地缓存
    ///
    /// - Parameter url: 资源路径
    /// - Returns: 返回Data资源
    class func getAdDataFromLocal(_ url: String) -> Data? {
        guard let filePath = self.filePath(url) else {
            return nil
        }
        let data = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Data
        return data
    }
    
    /// 删除本地缓存的广告资源
    ///
    /// - Parameter url: 资源路径
    /// - Returns: 返回ture表示删除成功，false删除失败
    public class func clearAdDataFromLocal(_ url: String) -> Bool {
        guard let filePath = self.filePath(url) else {
            return false
        }
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(at: URL.init(fileURLWithPath: filePath))
            } catch {
                print(error)
                return false
            }
        }
        return true
    }
    
    /// 删除本地所有缓存
    ///
    /// - Returns: 返回ture表示删除成功，false删除失败
    public class func clealAllLocalCache() -> Bool {
        guard let filePath = self.rootFilePath() else {
            return false
        }
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(at: URL.init(fileURLWithPath: filePath))
            } catch {
                print(error)
                return false
            }
        }
        return true
    }
    
    /// 获取本地缓存的文件路径，没有则创建一个
    ///
    /// - Parameter url: 资源路径
    /// - Returns: 返回保存广告资源的文件路径
    class func filePath(_ url: String) -> String? {
        guard let filePath = self.rootFilePath() else {
            return nil
        }
        // 把资源路径通过MD5加密后，作为文件的名称进行保存
        return (filePath as NSString).appendingPathComponent(url.td.md5 + ".data")
    }

    class func rootFilePath() -> String? {
        let docDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let filePath = (docDir as NSString).appendingPathComponent("LuanchAdDataSource")
        if !FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
                return nil
            }
        }
        return filePath
    }
}
