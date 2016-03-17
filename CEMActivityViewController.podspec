#
# Be sure to run `pod lib lint CEMActivityViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CEMActivityViewController"
  s.version          = "1.0.0"
  s.summary          = "Custom ActivityViewController on iOS"

# This description is used to generate tags and improve search results.
  s.description      = <<-DESC
   A Custom ActivityViewController on iOS like UIActivityViewController.
                       DESC

  s.homepage         = "https://github.com/svenhaun/CEMActivityViewController"
# s.screenshot       = 'https://github.com/svenhaun/CEMActivityViewController/blob/master/Screenshot.png'
  s.license          = 'MIT'
  s.author           = { "svenhaun" => "svenhaun@126.com" }
  s.source           = { :git => "https://github.com/svenhaun/CEMActivityViewController.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'

# s.resource_bundles = {
#   'CEMActivityViewController' => ['Pod/Resources/*.png']
# }

  s.resource = 'Pod/Resources/*.bundle'

#s.public_header_files = 'Pod/Classes/**/*.h'

    s.frameworks = 'UIKit', 'Foundation'
    s.dependency 'TencentOpenApiSDK/64bit', '~> 2.9.5'
    s.dependency 'libWeChatSDK', '~> 1.6'
    s.dependency 'WeiboSDK', '~> 3.1.3'
end
