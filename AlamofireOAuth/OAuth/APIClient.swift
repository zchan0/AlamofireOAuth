//
//  APIClient.swift
//  AlamofireOAuth1
//
//  Created by Cencen Zheng on 2018/4/3.
//  Copyright © 2018 Cencen Zheng. All rights reserved.
//

import Alamofire
import KeychainAccess

open class APIClient: RequestAdapter {
    open var sessionManager: SessionManager
    open var keychain: Keychain
    open static var `default` = APIClient()
    
    fileprivate let oauth1: OAuth1
    fileprivate let tokenId: String
    fileprivate let errorHandler: (Error) -> Void = { (error) in
        print(error.localizedDescription)
    }
    
    init(withOAuth oauth: OAuth1) {
        self.keychain = Keychain()
        self.oauth1 = OAuth1(withOAuth: oauth)
        self.tokenId = oauth1.key
        self.sessionManager = SessionManager()
        self.sessionManager.adapter = self
    }
    
    // default APIClient
    private init() {
        self.oauth1 = OAuth1()
        self.tokenId = oauth1.key
        self.keychain = Keychain()
        self.sessionManager = SessionManager()
        self.sessionManager.adapter = self
    }
    
    open func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        let accessToken = try OAuth1TokenStore.shared.retrieveCurrentToken(withIdentifier: tokenId)
        return try oauth1.adaptRequest(urlRequest, withAccessToken: accessToken)
    }
    
    public func request(_ router: URLRequestConvertible) -> DataRequest {
        return sessionManager.request(router)
    }
    
    public func authorize(withAuthorizeURLHandler authorizeURLHandler: OAuthOpenURLHandler? = nil, completion: @escaping () -> Void) {
        if let URLHandler = authorizeURLHandler {
            oauth1.authorizeURLHandler = URLHandler
        }
        oauth1.fetchAccessToken(accessMethod: .get, successHandler: { (accessToken) in
            OAuth1TokenStore.shared.saveToken(accessToken, withIdentifier: self.tokenId)
            completion()
        }, failureHandler: errorHandler)
    }
}
