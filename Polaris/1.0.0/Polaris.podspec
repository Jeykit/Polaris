#
# Be sure to run `pod lib lint Polaris.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
# pod repo push Polaris Polaris.podspec --allow-warnings --use-libraries
# pod trunk register 392071745@qq.com 'Jekity' --verbose
# pod trunk push MUKit.podspec --use-libraries --allow-warnings
#

Pod::Spec.new do |s|
  s.name             = 'Polaris'
  s.version          = '1.0.0'
  s.summary          = 'Ease to use in iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
实现Flebox布局/信号/导航/TableView
                       DESC

  s.homepage         = 'https://github.com/Jeykit/Polaris'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jeykit' => '392071745@qq.com' }
  s.source           = { :git => 'https://github.com/Jeykit/Polaris.git', :tag => s.version }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Polaris/Classes/Polaris.h'
  
  # s.resource_bundles = {
  #   'Polaris' => ['Polaris/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/Polaris.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.subspec 'Layout' do |ss|
      ss.source_files = 'Polaris/Classes/Layout/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/Layout/*.h'
  end
  s.subspec 'TableView' do |ss|
      ss.dependency 'Polaris/Layout'
      ss.dependency 'Polaris/Refresh'
      ss.dependency 'Polaris/TipsView'
      ss.dependency 'Polaris/Public'
      ss.source_files = 'Polaris/Classes/TableView/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/TableView/*.h'
  end
  s.subspec 'CollectionView' do |ss|
      ss.dependency 'Polaris/Layout'
      ss.dependency 'Polaris/Refresh'
      ss.dependency 'Polaris/TipsView'
      ss.dependency 'Polaris/Public'
      ss.source_files = 'Polaris/Classes/CollectionView/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/CollectionView/*.h'
  end
  s.subspec 'Signal' do |ss|
      ss.source_files = 'Polaris/Classes/Signal/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/Signal/*.h'
  end
  s.subspec 'Navigation' do |ss|
      ss.source_files = 'Polaris/Classes/Navigation/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/Navigation/*.h'
  end
  s.subspec 'Refresh' do |ss|
      ss.dependency 'Polaris/Normal'
      ss.source_files = 'Polaris/Classes/Refresh/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/Refresh/*.h'
  end
  s.subspec 'TipsView' do |ss|
      ss.source_files = 'Polaris/Classes/TipsView/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/TipsView/*.h'
  end
  s.subspec 'Public' do |ss|
      ss.source_files = 'Polaris/Classes/Public/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/Public/*.h'
  end
  s.subspec 'Normal' do |ss|
      ss.source_files = 'Polaris/Classes/Normal/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/Normal/*.h'
  end
  s.subspec 'PhotoPreview' do |ss|
      ss.source_files = 'Polaris/Classes/PhotoPreview/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/PhotoPreview/{PhotoPreviewController}.h'
  end
  # s.subspec 'NetworingManager' do |ss|
  #   ss.source_files = 'Polaris/Classes/NetworingManager/*.{h,m}'
  #   ss.public_header_files = 'Polaris/Classes/NetworingManager/*.h'
  #   ss.dependency 'YYModel'
  #   ss.dependency 'AFNetworking'
  #end
  s.subspec 'Carousel' do |ss|
      ss.source_files = 'Polaris/Classes/Carousel/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/Carousel/*.h'
  end
  s.subspec 'PhotoManager' do |ss|
      ss.source_files = 'Polaris/Classes/PhotoManager/*.{h,m}'
      ss.public_header_files = 'Polaris/Classes/PhotoManager/{PSImagePickerManager,PSAuthorizationStatusController}.h'
      ss.dependency 'Polaris/PhotoPreview'
  end
  
end
