//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 18.01.2026.
//

@testable import ImageFeed
import UIKit

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?

    private(set) var bindCalled = false
    private(set) var viewDidLoadCalled = false
    private(set) var didTapLogoutCalled = false
    private(set) var didConfirmLogoutCalled = false
    
    func bind(view: ProfileViewControllerProtocol) {
        bindCalled = true
        self.view = view
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
    
    func didConfirmLogout() {
        didConfirmLogoutCalled = true
    }
}
