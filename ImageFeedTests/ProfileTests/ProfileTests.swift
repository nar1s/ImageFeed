//
//  ProfileTests.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 18.01.2026.
//

@testable import ImageFeed
import XCTest

@MainActor
final class ProfileTests: XCTestCase {
    
    func testProfileViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(with: presenter)
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    
    func testPresenterCallsDisplayProfileWithPlaceholdersWhenProfileIsNil() {
        // given
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceStub(profile: nil)
        let imageService = ProfileImageServiceStub(avatarURL: nil)
        let logoutService = LogoutServiceSpy()
        let notificationCenter = NotificationCenter()
        
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: imageService,
            logoutService: logoutService,
            notificationCenter: notificationCenter
        )
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.displayProfileCalled)
        XCTAssertEqual(viewController.name, "Имя не указано")
        XCTAssertEqual(viewController.login, "@неизвестный_пользователь")
        XCTAssertEqual(viewController.bio, "Профиль не заполнен")
    }
    
    func testPresenterCallsDisplayProfileWithRealDataWhenProfileExists() {
        // given
        let viewController = ProfileViewControllerSpy()
        let profile = Profile(username: "pavel", firstName: "Павел", lastName: "Кузнецов", bio: "iOS developer")
        let profileService = ProfileServiceStub(profile: profile)
        let imageService = ProfileImageServiceStub(avatarURL: nil)
        let logoutService = LogoutServiceSpy()
        let notificationCenter = NotificationCenter()
        
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: imageService,
            logoutService: logoutService,
            notificationCenter: notificationCenter
        )
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.displayProfileCalled)
        XCTAssertEqual(viewController.name, "Павел Кузнецов")
        XCTAssertEqual(viewController.login, "@pavel")
        XCTAssertEqual(viewController.bio, "iOS developer")
    }
    
    func testPresenterCallsDisplayAvatarWithURLWhenAvatarURLExists() {
        // given
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceStub(profile: nil)
        let imageService = ProfileImageServiceStub(avatarURL: "https://example.com/avatar.png")
        let logoutService = LogoutServiceSpy()
        let notificationCenter = NotificationCenter()
        
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: imageService,
            logoutService: logoutService,
            notificationCenter: notificationCenter
        )
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.displayAvatarCalled)
        XCTAssertEqual(viewController.avatarURL?.absoluteString, "https://example.com/avatar.png")
    }
    
    func testPresenterDidTapLogoutCallsShowLogoutConfirmation() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceStub(profile: nil),
            profileImageService: ProfileImageServiceStub(avatarURL: nil),
            logoutService: LogoutServiceSpy(),
            notificationCenter: NotificationCenter()
        )
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.didTapLogout()
        
        // then
        XCTAssertTrue(viewController.showLogoutConfirmationCalled)
    }
    
    func testPresenterDidConfirmLogoutCallsLogoutService() {
        // given
        let viewController = ProfileViewControllerSpy()
        let logoutService = LogoutServiceSpy()
        
        let presenter = ProfilePresenter(
            profileService: ProfileServiceStub(profile: nil),
            profileImageService: ProfileImageServiceStub(avatarURL: nil),
            logoutService: logoutService,
            notificationCenter: NotificationCenter()
        )
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.didConfirmLogout()
        
        // then
        XCTAssertTrue(logoutService.logoutCalled)
    }
    
    func testPresenterUpdatesAvatarOnNotification() async {
        // given
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceStub(profile: nil)
        let imageService = ProfileImageServiceStub(avatarURL: "https://example.com/avatar.png")
        let logoutService = LogoutServiceSpy()
        let notificationCenter = NotificationCenter()
        
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: imageService,
            logoutService: logoutService,
            notificationCenter: notificationCenter
        )
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()
        viewController.displayAvatarCalled = false
        viewController.avatarURL = nil
        
        let exp = expectation(description: "Avatar updated after notification")
        viewController.onDisplayAvatar = { _ in exp.fulfill() }
        
        // when
        notificationCenter.post(name: imageService.didChangeNotification, object: nil)
        
        // then
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(viewController.displayAvatarCalled)
        XCTAssertEqual(viewController.avatarURL?.absoluteString, "https://example.com/avatar.png")
    }
}

