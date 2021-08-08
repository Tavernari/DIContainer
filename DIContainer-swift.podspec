Pod::Spec.new do |s|
    s.name             = "DIContainer-swift"
    s.version          = "0.1.2"
    s.summary          = "Ultra-light dependency injection container framework for Swift"
    s.description      = "DIContainer is a dependency injection container framework for Swift, to help for handle the dependencies in your system."
  
    s.homepage         = "https://github.com/Tavernari/DIContainer"
    s.license          = 'MIT'
    s.author           = 'DIContainer Contributors'
    s.source           = { :git => "https://github.com/Tavernari/DIContainer", :tag => s.version.to_s }
  
    s.swift_version    = '5.1'
    s.source_files     = 'Sources/**/*.{swift,h}'
  
    s.ios.deployment_target     = '9.0'
    s.osx.deployment_target     = '10.10'
    s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target    = '9.0'
  end