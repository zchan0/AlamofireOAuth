//
//  APIClient.swift
//  AlamofireOAuth1
//
//  Created by Cencen Zheng on 2018/4/3.
//  Copyright © 2018 Cencen Zheng. All rights reserved.
//

import Alamofire

open class APIClient: RequestAdapter {
    open var sessionManager: SessionManager
    open static var `default` = APIClient()
    
    fileprivate let oauth1: OAuth1
    fileprivate let errorHandler: (Error) -> Void = { (error) in
        print(error.localizedDescription)
    }
    
    private init() {
        self.oauth1 = OAuth1()
        self.sessionManager = SessionManager()
        self.sessionManager.adapter = self
    }
    
    open func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return try oauth1.adaptRequest(urlRequest)
    }
    
    public func request(_ router: URLRequestConvertible) -> DataRequest {
        return sessionManager.request(router)
    }
    
    func authorize(withAuthorizeURLHandler authorizeURLHandler: OAuthOpenURLHandler? = nil, completion: @escaping () -> Void) {
        if let URLHandler = authorizeURLHandler {
            oauth1.authorizeURLHandler = URLHandler
        }
        oauth1.fetchAccessToken(withCallbackUrl: OAuth1Settings.CallbackUrl,
                                accessMethod: .get,
                                successHandler: completion,
                                failureHandler: errorHandler)
    }
}
