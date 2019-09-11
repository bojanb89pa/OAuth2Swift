# OAuth2Swift (using Alamofire 5 + Swift 5)
Basic sample for standard OAuth 2.0 protocol (adapted for Spring security) written in Swift 5 using Alamofire 5.

Backend sample for this written in Java (Spring):
https://github.com/bojanb89pa/OAuth2Spring. This is standard OAuth 2.0 use-case. It can be modified.

## Usage

Open terminal at root and run:

`pod install`

Open workspace - OAuth2Swift.xcworkspace.

Configure your DEBUG_SERVER_URL (and SERVER_URL) at OAuth2Swift/Info.plist. If you use HTTP without SSL certificate, you should update exception domains list in arbitraty loads configuration in Info.plist. If you follow instructions from https://github.com/bojanb89pa/OAuth2Spring, you should be able to run this application on simulator with url http://localhost:8080 (current configuration).
