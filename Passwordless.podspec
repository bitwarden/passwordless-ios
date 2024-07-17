Pod::Spec.new do |s|
  s.name = "Passwordless"
  s.version = "0.0.1"
  s.summary = "Passwordless.dev's iOS SDK for passkey integration"
  s.description = <<-DESC
  The purpose of this SDK is to be able to easily integrate passkeys(https://developer.apple.com/passkeys/)
  into your iOS app with the help of the Passwordless.dev (https://bitwarden.com/products/passwordless/) 
  management system. 
                    DESC
  s.homepage = "https://github.com/bitwarden/passwordless-ios"
  s.license = "LICENSE_BITWARDEN.txt"
  s.author = "Bitwarden"
  s.platform = :ios, "16.0"
  s.swift_versions = ["5.7"]
  s.source = { :git => "https://github.com/bitwarden/passwordless-ios.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*"
end
