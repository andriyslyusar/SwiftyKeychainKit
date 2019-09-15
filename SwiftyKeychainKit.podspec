Pod::Spec.new do |spec|
  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  spec.name         = "SwiftyKeychainKit"
  spec.version      = "0.1.0"
  spec.summary      = "SwiftyKeychainKit is a simple Swift wrapper for Keychain Services API with the benefits of static typing."
  spec.description  = <<-DESC
                        SwiftyKeychainKit is a simple Swift wrapper for Keychain Services API with the benefits of static typing. 
                        Define your keys in one place, use value types easily, and get extra safety and convenient compile-time checks for free.

                        Features:
                        - Static typing and compile-time checks
                        - Swift 5 compatible
                      DESC

  spec.homepage     = "https://github.com/andriyslyusar/SwiftyKeychainKit"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  spec.author           = "Andriy Slyusar"
  spec.social_media_url = "https://twitter.com/andriyslyusar"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  spec.platform      = :ios, "12.0"
  spec.swift_version = '5.0'

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  spec.source = { :git => "https://github.com/andriyslyusar/SwiftyKeychainKit.git", :tag => "#{spec.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  spec.source_files = "Sources/*.swift"
end
