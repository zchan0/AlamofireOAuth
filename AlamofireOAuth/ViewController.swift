//
//  ViewController.swift
//  AlamofireOAuth1
//
//  Created by Cencen Zheng on 2018/4/6.
//  Copyright © 2018 zhengcc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = APIClient()
        client.setOAuth(withCallbackUrl: OAuth1Settings.CallbackUrl, requestMethod: .get, successHandler: { _ in
            client.request(Router.twitterHome).responseJSON(completionHandler: { (response) in
                debugPrint(response.result)
            })
        }, failureHandler: { (error) in
            print(error.localizedDescription)
        })
    }
}
