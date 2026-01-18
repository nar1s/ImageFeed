//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 14.01.2026.
//

import Foundation
import WebKit

protocol ProfileLogoutServiceProtocol: AnyObject {
    func logout()
}

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
    static let shared = ProfileLogoutService()      
    private init() { }

    func logout() {
        cleanCookies()
        cleanUserData()
        goToSplashScreen()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanUserData() {
        OAuth2TokenStorage.shared.deleteToken()
        ProfileService.shared.cleanProfile()
        ProfileImageService.shared.cleanProfileImage()
        ImagesListService.shared.clearImagesList()
    }
    
    private func goToSplashScreen() {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive } ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        
        guard
            let scene = windowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
        else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let splashScreen = SplashViewController()
        window.rootViewController = splashScreen
        window.makeKeyAndVisible()
    }
}
    
