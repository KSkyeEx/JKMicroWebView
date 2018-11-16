#
#  Be sure to run `pod spec lint JKMicroWebView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "JKMicroWebView"
  s.version      = "0.0.4"
  s.summary      = "对WKWebView的封装，提供了JS和OC交互的功能"
  s.description  = "对WKWebView的封装，提供了JS和OC交互的功能。"
  s.homepage     = "https://github.com/JokerKin/JKMicroWebView"
  s.license      = "MIT"
  s.author             = { "joker" => "https://github.com/JokerKin" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"

  s.public_header_files = 'JKMicroWebView/JKMicroWebView/JKMicroWebView/JKWebViewHeader.h'
  s.source       = { :git => "https://github.com/JokerKin/JKMicroWebView.git", :tag => "#{s.version}", :submodules => true}

  s.source_files  = "JKMicroWebView", "JKMicroWebView/JKMicroWebView/JKMicroWebView/**/*.{h,m}"

  s.subspec 'JKMicroJSBridge' do |sp|
    sp.source_files = 'JKMicroWebView/JKMicroWebView/JKMicroWebView/JKMicroJS{Bridge,Script}.{h,m}'
    sp.public_header_files = 'JKMicroWebView/JKMicroWebView/JKMicroWebView/JKMicroJSBridge.h'
  end
  s.subspec 'JKProgressView' do |sp|
    sp.source_files = 'JKMicroWebView/JKMicroWebView/JKMicroWebView/JKProgressView.{h,m}'
    sp.public_header_files = 'JKMicroWebView/JKMicroWebView/JKMicroWebView/JKProgressView.h'
  end
end
