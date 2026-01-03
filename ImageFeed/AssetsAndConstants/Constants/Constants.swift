//
//  Constants.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 02.01.2026.
//

import Foundation

enum Constants {
    static let accessKey = "LxmynCaDGJCn3GFcoR7xf_FqxcZJQnPwWGXlhi49Zsc"
    static let secretKey = "tQ5k1LnYaysaMCkDiBiDpcWVN9d_JO_lyQw5G6nACAA"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
} 

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}
