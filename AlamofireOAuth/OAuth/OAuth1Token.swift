//
//  OAuth1Token.swift
//  AlamofireOAuth1
//
//  Created by Cencen Zheng on 21/03/2018.
//  Copyright © 2018 Cencen Zheng. All rights reserved.
//

import Foundation

public struct OAuth1Token: Codable {
    var token: String           // "oauth_token"
    var tokenSecret: String     // "oauth_token_secret"
    var verifierCode: String?   // "oauth_verifier"
    
    init() {
        self.token = ""
        self.tokenSecret = ""
    }
    
    init?(query: String) {
        self.token = ""
        self.tokenSecret = ""
        
        if query.count == 0 {
            return nil
        }
        
        let parameters = self.parametersFrom(query: query)
        
        if let confirmed = parameters["oauth_callback_confirmed"], confirmed != "true" {
            print("Error: value for oauth_callback_confirmed is not true")
            return nil
        }
        
        guard let oauthToken = parameters["oauth_token"] else {
            print("Error: cannot find oauth_token field in \(query)")
            return nil
        }
        self.token = oauthToken.safeStringByRemovingPercentEncoding
        
        if let oauthTokenSecret = parameters["oauth_token_secret"] {
            self.tokenSecret = oauthTokenSecret.safeStringByRemovingPercentEncoding
        }
        
        if let verifier = parameters["oauth_verifier"] {
            self.verifierCode = verifier.safeStringByRemovingPercentEncoding
        }
    }
    
    // k1 = v1 & k2 = v2 & ... => [k1: v1, k2: v2, ...]
    private func parametersFrom(query: String) -> [String: String] {
        let scanner = Scanner(string: query)
        
        var key: NSString?
        var value: NSString?
        var parameters = [String: String]()
        
        while !scanner.isAtEnd {
            key = nil
            scanner.scanUpTo("=", into: &key)
            scanner.scanString("=", into: nil)
            
            value = nil
            scanner.scanUpTo("&", into: &value)
            scanner.scanString("&", into: nil)
            
            if let key = key as String?, let value = value as String? {
                parameters.updateValue(value, forKey: key)
            }
        }
        
        return parameters
    }
}

// MARK: OAuth1TokenStore

class OAuth1TokenStore {
    enum KeychainError: Error {
        case noToken
        case unexpectedTokenData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    static let shared = OAuth1TokenStore()
    
    private static let service = "AlamofireOAuth1Service"
    
    class func retrieveToken(withIdentifier identifier: String) throws -> OAuth1Token {
        // Build a query to find the item that matches the service, account.
        var query = OAuth1TokenStore.keychainQuery(withService: service, account: identifier)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noToken }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Parse the token string from the query result.
        guard
            let existingItem = queryResult as? [String : AnyObject],
            let tokenData = existingItem[kSecValueData as String] as? Data,
            let token = try? JSONDecoder().decode(OAuth1Token.self, from: tokenData)
        else {
            throw KeychainError.unexpectedTokenData
        }
        
        return token
    }
    
    class func deleteToken(withIdentifier identifier: String) throws {
        // Delete the existing item from the keychain.
        let query = OAuth1TokenStore.keychainQuery(withService: service, account: identifier)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    class func storeToken(_ token: OAuth1Token, withIdentifier identifier: String) throws {
        // Encode the token into an Data object.
        let tokenData = try JSONEncoder().encode(token)
        
        do {
            // Check for an existing item in the keychain.
            try _ = retrieveToken(withIdentifier: identifier)
            
            // Update the existing item with the new token.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = tokenData as AnyObject?
            
            let query = OAuth1TokenStore.keychainQuery(withService: service, account: identifier)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else {
                throw KeychainError.unhandledError(status: status)
            }
        }
        catch KeychainError.noToken {
            // No token was found in the keychain.
            // Create a dictionary to save as a new keychain item.
            var newItem = OAuth1TokenStore.keychainQuery(withService: service, account: identifier)
            newItem[kSecValueData as String] = tokenData as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else {
                throw KeychainError.unhandledError(status: status)
            }
        }
    }
    
    private class func keychainQuery(withService service: String, account: String) -> [String: AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject
        query[kSecAttrAccount as String] = account as AnyObject
        
        return query
    }
}

