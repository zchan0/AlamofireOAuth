//
//  ViewController.swift
//  AlamofireOAuth1
//
//  Created by Cencen Zheng on 2018/4/6.
//  Copyright © 2018 zhengcc. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var services = [
                    "Twitter",
                    "Fanfou"
                   ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Service Provider"
    }
}

// MARK: services

extension ViewController {
    func testTwitter() {
        APIClient.default.authorize {
            APIClient.default.request(Router.twitter).validate().responseJSON(completionHandler: { (response) in
                debugPrint(response.result)
            })
        }
    }
    
    func testFanfou() {
        let oauth1 = OAuth1(key: "f63b93431034993725507feafbddb099",
                            secret: "eba8823635402eeeb642befa0f122efb",
                            requestTokenUrl: "http://fanfou.com/oauth/request_token",
                            authorizeUrl: "http://fanfou.com/oauth/authorize",
                            accessTokenUrl: "http://fanfou.com/oauth/access_token",
                            callbackUrl: "alamofire-oauth1://callback")
        let client = APIClient(withOAuth: oauth1)
        client.authorize {
            client.request(Router.fanfou).validate().responseJSON(completionHandler: { (response) in
                debugPrint(response.result)
            })
        }
    }
}

// MARK: Table

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let service = services[indexPath.row]
        cell.textLabel?.text = service
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            testTwitter()
        case 1:
            testFanfou()
        default:
            break;
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
