platform :ios, '16.0'
use_frameworks!

install! 'cocoapods', :deterministic_uuids => false

target 'AfriVest' do
  pod 'Alamofire'
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/InAppMessaging'
  pod 'KeychainSwift'
  pod 'Kingfisher'
  pod 'lottie-ios'
  pod 'FlutterwaveSDK'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
