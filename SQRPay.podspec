Pod::Spec.new do |s|

  s.name         = "SQRPay"
  s.version      = "0.0.1"
  s.summary  	 = '支付'
  s.homepage     = "https://github.com/pengruiCode/SQRPay.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = {'pengrui' => 'pengruiCode@163.com'}
  s.source       = { :git => 'https://github.com/pengruiCode/SQRPay.git', :tag => s.version}
  s.platform 	 = :ios, "8.0"
  s.source_files = "SQRPay/**/*.{h,m}"
  s.requires_arc = true
  s.description  = <<-DESC
			实现支付宝和微信支付
                   DESC

  s.resource            = 'SQRPay/ALiPaySDK/AlipaySDK.bundle'
  s.vendored_libraries  = 'SQRPay/WeiChatSDK/*.a'
  s.vendored_frameworks = 'SQRPay/ALiPaySDK/*.framework'

 end