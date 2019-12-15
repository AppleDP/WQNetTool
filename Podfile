platform :ios,'9.0'
inhibit_all_warnings!

target 'WQNetTool' do
    pod 'CocoaAsyncSocket', '~> 7.6.3'
    
    # 布局库
    pod 'MyLayout', :path => 'LocalPods/MyLayout.podspec'
    
    # Control X
    pod 'SVProgressHUD'
    pod 'BlocksKit', '~> 2.2.5'
    pod 'IQKeyboardManager', '~> 5.0.7'
    pod 'AFNetworking', '~> 3.2.1'
    pod 'WQCategory', :path => 'LocalPods/WQCategory.podspec'
    pod 'WQLog', :path => 'LocalPods/WQLog.podspec'
    pod 'WQRuntimeKit', :path => 'LocalPods/WQRuntimeKit.podspec'
end

# 消除 pod 版本警告: The iOS deployment target is set to x.x, but the range of supported deployment target versions for this platform is y.y to x.x. (in target 'xxx')
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end
