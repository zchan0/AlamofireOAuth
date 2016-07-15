//
//  OAuth1.swift
//  AlamofireOAuth
//
//  Created by zhengcc on 7/14/16.
//  Copyright © 2016 zhengcc. All rights reserved.
//

import Foundation
import Alamofire

class OAuth1: OAuth {
    
    var consumer_key: String
    var consumer_secret: String
    var request_token_url: String
    var authorize_url: String
    var access_token_url: String
    
    init(consumerKey: String, consumerSecret: String, requestTokenUrl: String, authorizeUrl: String, accessTokenUrl: String){
        consumer_key      = consumerKey
        consumer_secret   = consumerSecret
        request_token_url = requestTokenUrl
        authorize_url     = authorizeUrl
        access_token_url  = accessTokenUrl
        super.init(consumerKey: consumerKey, consumerSecret: consumerSecret)
    }
    
    func fetchAccessTokenWith(callbackUrl url: String, completionHandler: (OAuthCredential) -> Void) {
        
        // step 1: get unauthorized reqeust token
        let parameters = signParameters(.GET, Url: request_token_url)
        Alamofire.request(.GET, request_token_url, parameters: parameters, encoding: .URLEncodedInURL, headers: nil)
            .responseString { response in
                guard let data = response.data else { return }
                let responseString = String(data: data, encoding: NSUTF8StringEncoding)!
                self.updateCredentialOAuthTokenAndTokenSecretWith(aString: responseString)
                
                //  step 3: get access token
                //          config callback action when get authorized request token
                self.observeCallbackWith(callback: { [weak self] (url) in
                    guard let `self` = self else { return }
                    if let authorizedRequestToken = url.query {
                        self.updateCredentialOAuthTokenAndTokenSecretWith(aString: authorizedRequestToken)
                    }
                    
                    let parameters = self.signParameters(.GET, Url: self.access_token_url)
                    Alamofire.request(.GET, self.access_token_url, parameters: parameters, encoding: .URLEncodedInURL, headers: nil).responseString { response in
                        guard let data = response.data else { return }
                        let responseString = String(data: data, encoding: NSUTF8StringEncoding)!
                        self.updateCredentialOAuthTokenAndTokenSecretWith(aString: responseString)
                        completionHandler(self.credential)
                    }
                })
                
                // step 2: authorize request token
                guard let handler = self.authorizeURLHandler else { return }
                let authorizeUrl = self.authorize_url + "?oauth_token=\(self.credential.oauth_token)" + "&oauth_callback=\(url)"
                handler.openURL(NSURL(string: authorizeUrl)!)
        }
    }
}

// MARK: - Helpers

extension OAuth1 {
    
    func signParameters(method: Alamofire.Method, Url: String) -> [String : String] {
        var parameters = authorizationParameters()
        let signature  = credential.sign(method, Url: Url, parammeters: parameters)
        parameters["oauth_signature"] = signature
        
        return parameters
    }
    
    func authorizationParameters() -> [String : String] {
        let nonce  = credential.generateNonce()
        let timestamp  = credential.timestamp()
        var parameters = [String : String]()
        
        parameters = [
            "oauth_consumer_key"     : credential.consumer_key,
            "oauth_token"            : credential.oauth_token,
            "oauth_token_secret"     : credential.oauth_token_secret,
            "oauth_signature_method" : credential.signature_method.rawValue,
            "oauth_version"          : credential.version.name,
            "oauth_timestamp"        : timestamp,
            "oauth_nonce"            : nonce
        ]
        
        return parameters
    }
    
    /**
     update self.credential's oauth_token & oauth_token_secret
     
     - parameter string: a key-value string, like "oauth_token = xxx & oauth_token_secret = xxx "
     */
    private func updateCredentialOAuthTokenAndTokenSecretWith(aString string: String) {
        let dict = string.generateParameters()
        if let oauthToken = dict["oauth_token"]{
            credential.oauth_token = oauthToken.safeStringByRemovingPercentEncoding
        }
        if let oauthTokenSecret = dict["oauth_token_secret"] {
            credential.oauth_token_secret = oauthTokenSecret.safeStringByRemovingPercentEncoding
        }
    }
}
