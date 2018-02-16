platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

target "MobileEngage" do
  if ENV["DEV"] then
    puts 'Running in DEV mode'
    pod 'CoreSDK', :path => '../ios-core-sdk/'
  elsif ENV["BLEEDING_EDGE"] then
    puts 'Running in BLEEDING_EDGE mode'
    pod 'CoreSDK', :git => 'https://github.com/emartech/ios-core-sdk.git'
  else
    pod 'CoreSDK', '1.0.0'
  end
end

target "MobileEngageTests" do
  pod 'Kiwi'
end
