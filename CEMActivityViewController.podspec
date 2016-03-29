Pod::Spec.new do |s|
  s.name             = "CEMActivityViewController"
  s.version          = "1.1.1"
  s.summary          = "Custom ActivityViewController on iOS"

  s.homepage         = "https://github.com/svenhaun/CEMActivityViewController"
  s.license          = 'MIT'
  s.author           = { "svenhaun" => "svenhaun@126.com" }
  s.source           = { :git => "https://github.com/svenhaun/CEMActivityViewController.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
    
  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.resource = "Pod/Resources/Resource.bundle"
#  s.resource_bundles = {
#    'Icons' => ['Pod/Resources/Resource.bundle/**/*.png'],
#  }

  s.public_header_files = ['Pod/Classes/CEMActivityViewController/Public/*.h', 'Pod/Classes/CEMSocialPlatformManager/*.h']
  s.private_header_files = 'Pod/Classes/CEMActivityViewController/Private/*.h'

  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'TencentOpenApiSDK/64bit', '~> 2.9.5'
  s.dependency 'libWeChatSDK', '~> 1.6'
  s.dependency 'WeiboSDK', '~> 3.1.3'

end
