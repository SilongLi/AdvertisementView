Pod::Spec.new do |s|
    s.name             = 'AdvertisementView'
    s.version          = '2.1.0'

    s.summary          = 'App启动广告页，支持播放Gif/png/jpg等。'
    s.homepage         = 'https://github.com/SilongLi/AdvertisementView.git'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'lisilong' => 'lisilong@tuandai.com' }
    s.source           = { :git => 'https://github.com/SilongLi/AdvertisementView.git', :tag => s.version.to_s }
    s.source_files     = 'AdvertisementView/Classes/**/*'

    s.description      = <<-DESC
                            App启动广告页，支持播放Gif/png/jpg等。（组件中已经监听了app的 UIApplicationDidFinishLaunching 通知，通知来了会把广告页添加到keyWindow中，使用者只需要创建即可。）
                         DESC

    s.requires_arc = true
    s.ios.deployment_target = '8.0'
    s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
    s.frameworks = 'Foundation', 'UIKit'
# s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/CommonCrypto" }
end

