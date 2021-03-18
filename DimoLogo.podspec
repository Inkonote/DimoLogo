#
# Be sure to run `pod lib lint DimoLogo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DimoLogo'
  s.version          = '0.4.0'
  s.summary          = 'Inkonote(滴墨书摘) logo view.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Provide Inkonote(滴墨书摘) logo view and loading view.
                       DESC

  s.homepage         = 'https://github.com/Inkonote/DimoLogo'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ty0x2333' => 'ty0x2333@gmail.com' }
  s.source           = { :git => 'https://github.com/Inkonote/DimoLogo.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ty0x2333'

  s.ios.deployment_target = '10.0'
  s.default_subspec = 'Core'

  s.swift_version = '5'

  s.subspec 'Core' do |ss|
    ss.source_files = 'DimoLogo/Classes/Core/**/*'
  end

  s.subspec 'HUD' do |ss|
    ss.source_files = 'DimoLogo/Classes/HUD/**/*'
    ss.dependency 'MBProgressHUD', '~> 1.2'
    ss.dependency 'DimoLogo/Core'
  end

  # s.resource_bundles = {
  #   'DimoLogo' => ['DimoLogo/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
