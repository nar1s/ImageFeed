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
    
    func testViewControllerCallsPresenterViewDidLoad() {
        //given
        let vc = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        vc.configure(with: presenter)
        
        //when
        vc.loadViewIfNeeded()
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewDidLoadWhenServiceEmptyTriggersFetchNextPage() {
        // given
        let service = ImagesListServiceSpy()
        service.photosStub = []
        let presenter = ImagesListPresenter(photoService: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertEqual(service.fetchPhotosNextPageCallCount, 1)
    }

    func testDidScrollBottomTriggersFetchNextPage() {
        // given
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(photoService: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view

        // when
        presenter.didScrollBottom()

        // then
        XCTAssertEqual(service.fetchPhotosNextPageCallCount, 1)
    }

    func testServiceNotificationReloadsDataOnFirstLoad() {
        // given
        let service = ImagesListServiceSpy()
        service.photosStub = []
        let presenter = ImagesListPresenter(photoService: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        presenter.viewDidLoad()

        service.photosStub = [makePhoto(id: "1", isLiked: false), makePhoto(id: "2", isLiked: true)]

        // when
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: service)

        // then (обработчик на .main)
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        XCTAssertTrue(view.reloadDataCalled)
    }

    func testDidTapPhotoOpensSingleImage() {
        // given
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(photoService: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        presenter.viewDidLoad()

        let photo = makePhoto(id: "1", isLiked: false)
        service.photosStub = [photo]
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: service)
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))

        // when
        presenter.didTapPhoto(at: IndexPath(row: 0, section: 0))

        // then
        XCTAssertEqual(view.openedPhoto?.id, "1")
    }

    func testDidTapLikeSuccessCallsServiceAndHidesLoading() {
        // given
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(photoService: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        presenter.viewDidLoad()

        service.photosStub = [makePhoto(id: "1", isLiked: false)]
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: service)
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))

        service.changeLikeResult = .success(true)

        // when
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))

        // then
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        XCTAssertTrue(view.showLoadingCalled)
        XCTAssertTrue(view.hideLoadingCalled)

        XCTAssertEqual(service.changeLikeCalledWith?.photoId, "1")
        // expected: лайкнуть, потому что было isLiked = false
        XCTAssertEqual(service.changeLikeCalledWith?.isLike, true)
    }

    func testDidTapLikeFailureShowsError() {
        // given
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(photoService: service)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        presenter.viewDidLoad()

        service.photosStub = [makePhoto(id: "1", isLiked: false)]
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: service)
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))

        service.changeLikeResult = .failure(URLError(.badServerResponse))

        // when
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))

        // then
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        XCTAssertTrue(view.showErrorCalled)
        XCTAssertTrue(view.hideLoadingCalled)
    }
}
