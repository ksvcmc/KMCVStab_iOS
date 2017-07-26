#
#  Be sure to run `pod spec lint KMCVStab.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "KMCVStab"
  s.version      = "1.0.0"
  s.summary      = "金山魔方防抖方案."
  s.ios.deployment_target = "8.0"
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
                   * 金山魔方视频拍摄防抖iOS: 五轴防抖效果，计算与传感器结合的算法，数字全局快门，实时运算，GPU加速。
                   DESC

  s.homepage     = "https://kmc.console.ksyun.com/"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = {:type => 'Proprietary', :text => <<-LICENSE
  Copyright 2015 kingsoft Ltd. All rights reserved.
  LICENSE
  }

  s.author             = { "Noiled" => "zhangjun5@kingsoft.com" }

  s.source       = { :git => "https://github.com/ksvcmc/KMCVstab_iOS.git", :tag => "v#{s.version}" }


  s.vendored_frameworks ="framework/KMCVStab.framework"
  s.requires_arc = true
end
