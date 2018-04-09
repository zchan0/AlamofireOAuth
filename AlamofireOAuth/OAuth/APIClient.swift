//
//  APIClient.swift
//  AlamofireOAuth1
//
//  Created by Cencen Zheng on 2018/4/3.
//  Copyright © 2018 Cencen Zheng. All rights reserved.
//

import Alamofire

open class APIClient: RequestAdapter {
    fileprivate var oauth1: OAuth1
    open var sessionManager: SessionManager
    
    init(key: String, secret: String, requestTokenUrl: String, authorizeUrl: String, accessTokenUrl: String) {
        self.oauth1 = OAuth1(key: key,
                             secret: secret,
                             requestTokenUrl: requestTokenUrl,
                             authorizeUrl: authorizeUrl,
                             accessTokenUrl: accessTokenUrl)
        self.sessionManager = SessionManager()
    }
    
    convenience init() {
        self.init(key: OAuth1Settings.ConsumerKey,
                  secret: OAuth1Settings.ConsumerSecret,
                  requestTokenUrl: OAuth1Settings.RequestTokenUrl,
                  authorizeUrl: OAuth1Settings.AuthorizeUrl,
                  accessTokenUrl: OAuth1Settings.AccessTokenUrl)
    }
    
    open func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return try oauth1.adaptRequest(urlRequest)
    }
    
    func setOAuth(
        withCallbackUrl callbackUrl: String,
        requestMethod: HTTPMethod,
        URLHandler: OAuthOpenURLHandler? = nil,
        successHandler: @escaping OAuth1.SuccessHandler,
        failureHandler: @escaping OAuth1.FailureHandler)
    {
        if let handler = URLHandler {
            oauth1.authorizeURLHandler = handler
        }
        
        oauth1.fetchAccessToken(withCallbackUrl: callbackUrl, accessMethod: requestMethod, successHandler: { (accessToken) in
            do {
                try OAuth1TokenStore.shared.storeToken(accessToken)
                self.sessionManager.adapter = self
                successHandler(accessToken)
            } catch {
                failureHandler(error)
            }
        }, failureHandler: failureHandler) 
    }
    
    func request(_ router: URLRequestConvertible) -> DataRequest {
        return sessionManager.request(router)
    }
}
