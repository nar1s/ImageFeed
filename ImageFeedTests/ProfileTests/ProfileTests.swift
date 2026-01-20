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

    // MARK: - Properties

    private var profileService: ProfileServiceStub!
    private var imageService: ProfileImageServiceStub!
    private var logoutService: LogoutServiceSpy!
    private var notificationCenter: NotificationCenter!

    private var presenter: ProfilePresenter!
    private var view: ProfileViewControllerSpy!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()

        profileService = ProfileServiceStub(profile: nil)
        imageService = ProfileImageServiceStub(avatarURL: nil)
        logoutService = LogoutServiceSpy()
        notificationCenter = NotificationCenter()

        presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: imageService,
            logoutService: logoutService,
            notificationCenter: notificationCenter
        )
        view = ProfileViewControllerSpy()
        view.presenter = presenter
        presenter.view = view
    }

    override func tearDown() {
        profileService = nil
        imageService = nil
        logoutService = nil
        notificationCenter = nil
        presenter = nil
        view = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testViewControllerCallsPresenterViewDidLoad() {
        // Given
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterMock()
        viewController.configure(with: presenterSpy)
        presenterSpy.view = viewController

        // When
        viewController.loadViewIfNeeded()

        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testPresenterCallsDisplayProfileWithPlaceholdersWhenProfileIsNil() {
        // Given
        profileService.profile = nil
        imageService.avatarURL = nil

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(view.displayProfileCalled)
        XCTAssertEqual(view.name, "Имя не указано")
        XCTAssertEqual(view.login, "@неизвестный_пользователь")
        XCTAssertEqual(view.bio, "Профиль не заполнен")
    }

    func testPresenterCallsDisplayProfileWithRealDataWhenProfileExists() {
        // Given
        let profile = Profile(username: "pavel", firstName: "Павел", lastName: "Кузнецов", bio: "iOS developer")
        profileService.profile = profile

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(view.displayProfileCalled)
        XCTAssertEqual(view.name, "Павел Кузнецов")
        XCTAssertEqual(view.login, "@pavel")
        XCTAssertEqual(view.bio, "iOS developer")
    }

    func testPresenterCallsDisplayAvatarWithURLWhenAvatarURLExists() {
        // Given
        imageService.avatarURL = "https://example.com/avatar.png"

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(view.displayAvatarCalled)
        XCTAssertEqual(view.avatarURL?.absoluteString, "https://example.com/avatar.png")
    }

    func testPresenterDidTapLogoutCallsShowLogoutConfirmation() {
        // When
        presenter.didTapLogout()

        // Then
        XCTAssertTrue(view.showLogoutConfirmationCalled)
    }

    func testPresenterDidConfirmLogoutCallsLogoutService() {
        // When
        presenter.didConfirmLogout()

        // Then
        XCTAssertTrue(logoutService.logoutCalled)
    }

    func testPresenterUpdatesAvatarOnNotification() async {
        // Given
        imageService.avatarURL = "https://example.com/avatar.png"
        presenter.viewDidLoad()
        view.displayAvatarCalled = false
        view.avatarURL = nil

        let exp = expectation(description: "Avatar updated after notification")
        view.onDisplayAvatar = { _ in exp.fulfill() }

        // When
        notificationCenter.post(name: imageService.didChangeNotification, object: nil)

        // Then
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(view.displayAvatarCalled)
        XCTAssertEqual(view.avatarURL?.absoluteString, "https://example.com/avatar.png")
    }

    // MARK: - Helpers
    private func waitForMainQueue() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }
}

