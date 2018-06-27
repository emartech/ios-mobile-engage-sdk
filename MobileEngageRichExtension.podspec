Pod::Spec.new do |spec|
	spec.name                 = 'MobileEngageRichExtension'
	spec.version              = '1.1.0'
	spec.homepage             = 'https://help.emarsys.com/hc/en-us/articles/115002410625'
	spec.license              = 'Mozilla Public License 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Mobile Engage iOS Extension SDK'
	spec.platform             = :ios, '9.0'
	spec.source               = { :git => 'https://github.com/emartech/ios-mobile-engage-sdk.git', :commit => '87368558ae95c10a97db1235d91c07e0862fe628' }
	spec.source_files         = 'MobileEngage/RichNotificationExtension/**/*.{h,m}'
	spec.public_header_files  = [
    'MobileEngage/RichNotificationExtension/MENotificationService.h'
	]
	spec.dependency 'CoreSDK', '1.7.0'
	spec.libraries = 'z', 'c++'
end
