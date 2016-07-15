//
//  OAuth.swift
//  AlamofireOAuth
//
//  Created by zhengcc on 7/14/16.
//  Copyright © 2016 zhengcc. All rights reserved.
//

import Foundation

class OAuth: NSObject {
    
    var observer: AnyObject?
    var credential: OAuthCredential
    var authorizeURLHandler: OAuthOpenURLHandler?
    var version: OAuthCredential.Version { return credential.version }
    
    struct CallbackNotification {
        static let notificationName = "AlamofireOAuthCallbackNotificationName"
        static let URLKey = "AlamofireOAuthCallbackNotificationURLKey"
    }
    
    init(consumerKey: String, consumerSecret: String) {
        credential = OAuthCredential(consumer_key: consumerKey, consumer_secret: consumerSecret)
    }
    
    class func handleOpenURL(url: NSURL) {
        let notification = NSNotification(name: CallbackNotification.notificationName, object: nil, userInfo: [CallbackNotification.URLKey : url])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func observeCallbackWith(callback block: (url: NSURL) -> Void) {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(CallbackNotification.notificationName, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) in
            self.removeCallbackObserver()
            if let userInfo = notification.userInfo, url = userInfo[CallbackNotification.URLKey] as? NSURL {
                block(url: url)
            }
        })
    }
    
    func removeCallbackObserver() {
        if let observer = observer {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
}