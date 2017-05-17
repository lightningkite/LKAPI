#
# Be sure to run `pod lib lint LKAPI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LKAPI"
  s.version          = "1.3.0"
  s.summary          = "Wrapper around Alamofire"
  s.description      = "Wrapper built around Alamofire to make working with APIs easier"
  s.homepage         = "https://github.com/Lightningkite/LKAPI"
  s.license          = 'MIT'
  s.author           = { "Erik Sargent" => "erik@lightningkite.com" }
  s.source           = { :git => "https://github.com/Lightningkite/LKAPI.git", :tag => s.version.to_s }

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.frameworks = 'SystemConfiguration'
  s.dependency 'Alamofire'
end
