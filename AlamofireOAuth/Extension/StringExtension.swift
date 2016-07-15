//
//  StringExtension.swift
//  AlamofireOAuth
//
//  Created by zhengcc on 7/14/16.
//  Copyright © 2016 zhengcc. All rights reserved.
//

import Foundation

extension String {
    
    func URLEncode() -> String? {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    }
    
    /**
     k1 = v1 & k2 = v2 & ... => [k1 : v1, k2 : v2, ...]
     
     */
    func generateParameters() -> [String : String] {
        var dicts = [String : String]()
        self.componentsSeparatedByString("&").forEach {
            let array = $0.componentsSeparatedByString("=")
            dicts.updateValue(array[1], forKey: array[0])
        }
        return dicts
    }
    
    func contains(aString: String) -> Bool {
        return self.rangeOfString(aString) != nil
    }
    
    var safeStringByRemovingPercentEncoding: String {
        return self.stringByRemovingPercentEncoding ?? self
    }
}