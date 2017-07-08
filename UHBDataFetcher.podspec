#
# Be sure to run `pod lib lint UHBDataFetcher.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UHBDataFetcher'
  s.version          = '1.0.0'
  s.summary          = 'A background data fetcher for iOS written in SWIFT 3 with caching ability'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'UHBDataFetcher lets you download any form of data in background with caching ability. It also provides you UIImageView extension to download and show images in your app with caching ability. Hard cache will be implemented soon.'

  s.homepage         = 'https://github.com/umairhassanbaig/UHBDataFetcher'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'umairhassanbaig@gmail.com' => 'umairhassanbaig@gmail.com' }
  s.source           = { :git => 'https://github.com/umairhassanbaig@gmail.com/UHBDataFetcher.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'UHBDataFetcher/Classes/**/*'
  
  # s.resource_bundles = {
  #   'UHBDataFetcher' => ['UHBDataFetcher/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
