//
//  ImagesListTests.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 18.01.2026.
//


@testable import ImageFeed
import XCTest

@MainActor
final class ImagesListTests: XCTestCase {

    // MARK: - Properties

    private var service: ImagesListServiceMock!
    private var presenter: ImagesListPresenter!
    private var view: ImagesListViewControllerSpy!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()

        service = ImagesListServiceMock()
        presenter = ImagesListPresenter(photoService: service)
        view = ImagesListViewControllerSpy()
        presenter.view = view
    }

    override func tearDown() {
        service = nil
        presenter = nil
        view = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testViewControllerCallsPresenterViewDidLoad() {
        // Given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterMock()
        viewController.configure(with: presenterSpy)

        // When
        viewController.loadViewIfNeeded()

        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testViewDidLoadWhenServiceEmptyTriggersFetchNextPage() {
        // Given
        service.photosStub = []

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertEqual(service.fetchPhotosNextPageCallCount, 1)
    }

    func testDidScrollBottomTriggersFetchNextPage() {
        // Given
        presenter.viewDidLoad()

        // When
        presenter.didScrollBottom()

        // Then
        XCTAssertEqual(service.fetchPhotosNextPageCallCount, 2)
    }

    func testServiceNotificationReloadsDataOnFirstLoad() {
        // Given
        service.photosStub = []
        presenter.viewDidLoad()

        service.photosStub = [
            makePhoto(id: "1", isLiked: false),
            makePhoto(id: "2", isLiked: true)
        ]

        // When
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: service
        )
        waitForMainQueue()

        // Then
        XCTAssertTrue(view.reloadDataCalled)
    }

    func testDidTapPhotoOpensSingleImage() {
        // Given
        let photo = makePhoto(id: "1", isLiked: false)
        service.photosStub = [photo]
        presenter.viewDidLoad()

        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: service
        )
        waitForMainQueue()

        // When
        presenter.didTapPhoto(at: IndexPath(row: 0, section: 0))

        // Then
        XCTAssertEqual(view.openedPhoto?.id, "1")
    }

    func testDidTapLikeSuccessCallsServiceAndHidesLoading() {
        // Given
        let photo = makePhoto(id: "1", isLiked: false)
        service.photosStub = [photo]
        service.changeLikeResult = .success(true)
        presenter.viewDidLoad()

        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: service
        )
        waitForMainQueue()

        // When
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        waitForMainQueue()

        // Then
        XCTAssertTrue(view.showLoadingCalled)
        XCTAssertTrue(view.hideLoadingCalled)
        XCTAssertEqual(service.changeLikeCalledWith?.photoId, "1")
        XCTAssertEqual(service.changeLikeCalledWith?.isLike, true)
    }

    func testDidTapLikeFailureShowsError() {
        // Given
        let photo = makePhoto(id: "1", isLiked: false)
        service.photosStub = [photo]
        service.changeLikeResult = .failure(URLError(.badServerResponse))
        presenter.viewDidLoad()

        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: service
        )
        waitForMainQueue()

        // When
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        waitForMainQueue()

        // Then
        XCTAssertTrue(view.showErrorCalled)
        XCTAssertTrue(view.hideLoadingCalled)
    }

    // MARK: - Helpers

    private func waitForMainQueue() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }
}

