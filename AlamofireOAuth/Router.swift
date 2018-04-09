//
//  LoginRouter.swift
//  AlamofireOAuth1
//
//  Created by Cencen Zheng on 2018/4/4.
//  Copyright © 2018 Cencen Zheng. All rights reserved.
//

import Alamofire

enum Router: URLRequestConvertible {
    case fanfouHome
    case twitterHome
    
    static let baseUrl = OAuth1Settings.BaseUrl
    
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters?, method: HTTPMethod) = {
            switch self {
            case .fanfouHome:
                return ("statuses/home_timeline.json", nil, .get)
            case .twitterHome:
                return ("statuses/user_timeline.json", nil, .get)
            }
        }()
        
        let url = try Router.baseUrl.asURL()
        let urlRequest = try URLRequest(url: url.appendingPathComponent(result.path),
                                        method: result.method)
        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
    }
}
