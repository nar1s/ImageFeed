//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 02.01.2026.
//

import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}

    private let defaults = UserDefaults.standard
    private let tokenKey = "com.imagefeed.oauth.bearerToken"
    
    var token: String? {
        get {
            defaults.string(forKey: tokenKey)
        }
        set {
            if let value = newValue {
                defaults.set(value, forKey: tokenKey)
            } else {
                defaults.removeObject(forKey: tokenKey)
            }
        }
    }
}

