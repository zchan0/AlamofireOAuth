//
//  OAuthOpenURLHandler.swift
//  AlamofireOAuth1
//
//  Created by Cencen Zheng on 27/03/2018.
//  Copyright © 2018 Cencen Zheng. All rights reserved.
//

import UIKit
import SafariServices

struct OAuthOpenURLHandlerNotification {
    static let CallbackName = Notification.Name(rawValue: "AlamofireOAuthCallbackNotificationName")
    static let CallbackUrlKey = "AlamofireOAuthCallbackNotificationURLKey"
}

protocol OAuthOpenURLHandler {
    func openURL(URL: URL)
}

class SafariOpenURLHandler: NSObject, OAuthOpenURLHandler {
    func openURL(URL: URL) {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
    }
}

class SafariViewControllerHandler: NSObject, OAuthOpenURLHandler {
    var viewController: UIViewController
    var observers = [String : Any]()
    
    var animated: Bool = true
    var presentCompletion: (() -> ())?
    var dismissCompletion: (() -> ())?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
    }
    
    func openURL(URL: URL) {
        let controller = SFSafariViewController(url: URL)
        let key = UUID().uuidString
        
        observers[key] = NotificationCenter.default.addObserver(forName: OAuthOpenURLHandlerNotification.CallbackName, object: nil, queue: OperationQueue.main) { notification in
            if let observer = self.observers[key] {
                NotificationCenter.default.removeObserver(observer)
                self.observers.removeValue(forKey: key)
            }
            
            controller.dismiss(animated: self.animated, completion: self.dismissCompletion)
        }
        
        viewController.present(controller, animated: animated, completion: presentCompletion)
    }
}
