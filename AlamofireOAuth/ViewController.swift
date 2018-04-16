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
        
        APIClient.default.authorize {
            APIClient.default.request(Router.twitterHome).validate().responseJSON(completionHandler: { (response) in
                debugPrint(response.result)
            })
        }
    }
}
