Pod::Spec.new do |spec|
	spec.name                 = 'MobileEngageSDK'
	spec.version              = '0.1.1'
	spec.homepage             = 'http://documentation.emarsys.com/'
	spec.license              = 'Apache License, Version 2.0'
    spec.author               = { 'Emarsys Technologies' => 'mobile-team@emarsys.com' }
	spec.summary              = 'Mobile Engage iOS SDK'
	spec.platform             = :ios, '9.0'
	spec.source               = { :git => 'git@github.com:emartech/ios-mobile-engage-sdk.git', :tag => spec.version }
	spec.source_files         = 'MobileEngage/**/*.{h,m}'
	spec.public_header_files  = [
		'MobileEngage/MobileEngage.h',
		'MobileEngage/MobileEngageStatusDelegate.h',
		'MobileEngage/MEConfigBuilder.h',
		'MobileEngage/MEConfig.h',
	]
	spec.dependency 'CoreSDK'
	spec.libraries = 'z', 'c++'
end
