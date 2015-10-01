#
# Be sure to run `pod lib lint Mopub-helper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Mopub-helper"
  s.version          = "4.91"
  s.summary          = "A Mopub helper to add Advertising very quickly."

  s.homepage         = "https://github.com/linked67/mopub-helper"
  s.license          = { :type => 'MIT',
                         :text => 'Mopub-helper uses MIT Licensing And so all of my source code can
                           be used royalty-free into your app. Just make sure that you don’t
                           remove the copyright notice from the source code if you make your
                           app open source and in the about page.' }
  s.author           = { "Heitz Bruno" => "hbdev.smart@yahoo.fr" }
  s.source           = { :git => "https://github.com/linked67/mopub-helper.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'MopubBannerSingleton.{h,m}'
  s.exclude_files = "MopubKeys.{h,m}"

  def s.post_install(target)
  puts <<-TEXT
  * Mopuh-helper note *
  Don't forget to create MopubKeys.h
  You can find an example here: https://github.com/linked67/mopub-helper/MopubKeys.h
  TEXT
  end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  # s.dependency 'Google-Mobile-Ads-SDK', '~> 7.0'
  # s.dependency 'mopub-ios-sdk'
  
end
