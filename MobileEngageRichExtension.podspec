Pod::Spec.new do |spec|
	spec.name                 = 'MobileEngageRichExtension'
	spec.version              = '1.2.0'
	spec.homepage             = 'https://help.emarsys.com/hc/en-us/articles/115002410625'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Mobile Engage iOS Extension SDK'
	spec.platform             = :ios, '9.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-mobile-engage-sdk.git', :commit => 'a79f04151361a2d09f83984797f7720a536c280d' }
	spec.source_files         = 'MobileEngage/RichNotificationExtension/**/*.{h,m}'
	spec.public_header_files  = [
    'MobileEngage/RichNotificationExtension/MENotificationService.h'
	]
	spec.dependency 'CoreSDK'
	spec.libraries = 'z', 'c++'
end
