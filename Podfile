platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/emartech/pod-private.git'

target "MobileEngage" do
  if ENV["DEV"] then
    puts 'Running in DEV mode'
    pod 'CoreSDK', :path => '../ios-core-sdk/'
  else
    pod 'CoreSDK'
  end
end

target "MobileEngageTests" do
  pod 'Kiwi'
end
