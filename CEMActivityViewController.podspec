Pod::Spec.new do |s|
  s.name             = "CEMActivityViewController"
  s.version          = "1.0.0"
  s.summary          = "Custom ActivityViewController on iOS"

  s.homepage         = "https://github.com/svenhaun/CEMActivityViewController"
  s.license          = 'MIT'
  s.author           = { "svenhaun" => "svenhaun@126.com" }
  s.source           = { :git => "https://github.com/svenhaun/CEMActivityViewController.git", :tag => s.version_to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.resources = 'Pod/Resources/Resource.bundle/**/*.png'

  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'TencentOpenApiSDK/64bit', '~> 2.9.5'
  s.dependency 'libWeChatSDK', '~> 1.6'
  s.dependency 'WeiboSDK', '~> 3.1.3'

end
