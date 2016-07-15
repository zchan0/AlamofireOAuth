//
//  OAuthCredential.swift
//  AlamofireOAuth
//
//  Created by zhengcc on 7/14/16.
//  Copyright © 2016 zhengcc. All rights reserved.
//

import Foundation
import Alamofire
import CryptoSwift

private let equalEncoded = "%3D"
private let ampersandEncoded = "%26"

class OAuthCredential: NSObject {
    
    enum SignatureMethod: String {
        case HMAC_SHA1 = "HMAC-SHA1"
        
        func sign(key: String, message: String) -> String {
            let result: [UInt8] = try! Authenticator.HMAC(key: Array(key.utf8), variant: .sha1).authenticate(Array(message.utf8))
            return result.toBase64()!
        }
    }
    
    enum Version {
        case OAuth1, OAuth2
        
        var name: String {
            switch self {
            case .OAuth1:
                return "1.0"
            case .OAuth2:
                return "2.0"
            }
        }
    }
    
    var consumer_key = ""
    var consumer_secret = ""
    var oauth_token = ""
    var oauth_token_secret = ""
    var version: Version = .OAuth1
    var signature_method: SignatureMethod = .HMAC_SHA1
    
    init(consumer_key: String, consumer_secret: String){
        self.consumer_key = consumer_key
        self.consumer_secret = consumer_secret
    }
    
    init(oauth_token: String, oauth_token_secret: String){
        self.oauth_token = oauth_token
        self.oauth_token_secret = oauth_token_secret
    }
    
    func sign(method: Alamofire.Method, Url: String, parammeters: [String : String] ) -> String {
        let encodedUrl    = Url.URLEncode()
        let encodedParams = parammeters.sort { $0.0 < $1.0 }.map { $0 + equalEncoded + $1 }.joinWithSeparator(ampersandEncoded)
        let baseUrl = "\(method)&\(encodedUrl!)&\(encodedParams)"
        let signKey = "\(consumer_secret)&\(oauth_token_secret)"
        
        return self.signature_method.sign(signKey, message: baseUrl)
    }
    
    func timestamp() -> String {
        return String(Int64(NSDate().timeIntervalSince1970))
    }
    
    func generateNonce() -> String {
        return  (NSUUID().UUIDString as NSString).substringToIndex(8)
    }
}