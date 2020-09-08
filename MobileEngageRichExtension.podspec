Pod::Spec.new do |spec|
	spec.name                 = 'MobileEngageRichExtension'
	spec.version              = '1.2.2'
	spec.homepage             = 'https://help.emarsys.com/hc/en-us/articles/115002683889'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Mobile Engage iOS Extension SDK'
	spec.platform             = :ios, '9.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-mobile-engage-sdk.git', :commit => '4021f488fc2a97aa259d764e0bee526a7aa68576' }
	spec.source_files         = 'MobileEngage/RichNotificationExtension/**/*.{h,m}'
	spec.public_header_files  = [
    'MobileEngage/RichNotificationExtension/MENotificationService.h'
	]
	spec.dependency 'CoreSDK', '1.7.3'
	spec.libraries = 'z', 'c++'
end
