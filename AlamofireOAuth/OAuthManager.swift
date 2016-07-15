//
//  OAuthManager.swift
//  AlamofireOAuth
//
//  Created by zhengcc on 7/15/16.
//  Copyright © 2016 zhengcc. All rights reserved.
//

import Foundation

class OAuthManager: NSObject {
    
    struct OAuthUpdateNotification {
        static let notificationName = "OAuthUpdateNotification"
        static let userInfoKey = "OAuthUpdateNotificationUserInfoKey"
    }
    
    var currentOAuth: OAuth? {
        didSet {
            if let newOAuth = currentOAuth {
                NSNotificationCenter.defaultCenter().postNotificationName(OAuthUpdateNotification.notificationName, object: nil, userInfo: [OAuthUpdateNotification.userInfoKey : newOAuth])
            }
        }
    }
    
    static let sharedManager: OAuthManager = OAuthManager()
    
    private override init() { }
}