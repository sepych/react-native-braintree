
Pod::Spec.new do |s|
  s.name         = "RNBraintree"
  s.version      = "1.0.0"
  s.summary      = "RNBraintree"
  s.description  = <<-DESC
                  RNBraintree
                   DESC
  s.homepage     = "https://home.page"
  s.license      = "MIT"
  s.author       = { "author" => "author@domain.cn" }
  s.platform     = :ios, '9.0'
  s.ios.deployment_target  = '9.0'
  s.source       = { :git => "https://github.com/author/RNBraintree.git", :tag => "master" }
  s.source_files = '**/*.{h,m}'
  s.requires_arc = true

  s.dependency "React"

end
