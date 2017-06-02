platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

target "MobileEngage" do
  if ENV["BLEEDING_EDGE"] then
    pod 'CoreSDK', :git => 'https://github.com/emartech/ios-core-sdk.git'
  else
    pod 'CoreSDK'
  end
end

target "MobileEngageTests" do
  pod 'Kiwi'
end
