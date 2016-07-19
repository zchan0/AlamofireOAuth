//
//  OAuthOpenURLHandler.swift
//  AlamofireOAuth
//
//  Created by zhengcc on 7/14/16.
//  Copyright © 2016 zhengcc. All rights reserved.
//

import Foundation
import SafariServices

protocol OAuthOpenURLHandler {
    func openURL(url: NSURL)
}

class ExternalOpenURLHandler: NSObject, OAuthOpenURLHandler {
    
    func openURL(url: NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }
}


@available(iOS 9.0, *)
class SafariOpenURLHandler: NSObject, OAuthOpenURLHandler {
    
    var viewController: UIViewController
    var observers = [String : AnyObject]()
    
    var animated: Bool = false
    var presentCompletion: (() -> ())?
    var dismissCompletion: (() -> ())?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func openURL(url: NSURL) {
        let controller = SFSafariViewController(URL: url)
        let key = NSUUID().UUIDString
        
        observers[key] = NSNotificationCenter.defaultCenter().addObserverForName(OAuth.CallbackNotification.notificationName, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] notification in
            guard let `self` = self else { return }
            
            if let observer = self.observers[key] {
                NSNotificationCenter.defaultCenter().removeObserver(observer)
                self.observers.removeValueForKey(key)
            }
            
            controller.dismissViewControllerAnimated(self.animated, completion: self.dismissCompletion)
        }
        
        viewController.presentViewController(controller, animated: animated, completion: presentCompletion)
    }
}

