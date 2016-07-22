//
//  ViewController.swift
//  AlamofireOAuth
//
//  Created by zhengcc on 7/14/16.
//  Copyright © 2016 zhengcc. All rights reserved.
//

import UIKit

private let ConsumerKey      = "f63b93431034993725507feafbddb099"
private let ConsumerSecret   = "eba8823635402eeeb642befa0f122efb"
private let RequestTokenUrl  = "http://fanfou.com/oauth/request_token"
private let AccessTokenUrl   = "http://fanfou.com/oauth/access_token"
private let AuthorizeUrl     = "http://fanfou.com/oauth/authorize"

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let oauth1 = OAuth1(consumerKey: ConsumerKey, consumerSecret: ConsumerSecret, requestTokenUrl: RequestTokenUrl, authorizeUrl: AuthorizeUrl, accessTokenUrl: AccessTokenUrl)
        let callbackUrl = "afoauth://callback"
        
        if #available(iOS 9.0, *) {
            let safariHandler = SafariOpenURLHandler(viewController: self)
            safariHandler.animated = false
            oauth1.authorizeURLHandler = safariHandler
            oauth1.fetchAccessTokenWith(callbackUrl: callbackUrl, completionHandler: { oauth in
                print(oauth.credential.oauth_token)
                print(oauth.credential.oauth_token_secret)
            })

        } else {
            // Fallback on earlier versions
            NSLog("support earlier versions")
        }
    }

}

