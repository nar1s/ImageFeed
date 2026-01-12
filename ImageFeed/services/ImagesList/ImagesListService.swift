//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 12.01.2026.
//

import Foundation
import CoreGraphics

final class ImagesListService {
    
    // MARK: - Properties
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var isLoading = false
    private let perPage = 10
    
    // MARK: - Public methods
    
    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        if isLoading { return }
        isLoading = true
        
        guard let request = makePhotosRequest(page: nextPage, perPage: perPage) else {
            isLoading = false
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let photoResults):
                let mapped: [Photo] = photoResults.compactMap { result in
                    guard
                        let id = result.id,
                        let width = result.width,
                        let height = result.height,
                        let thumb = result.thumbImageURL,
                        let large = result.largeImageURL
                    else {
                        return nil
                    }
                    
                    let size = CGSize(width: width, height: height)
                    return Photo(
                        id: id,
                        size: size,
                        createdAt: result.createdAt,
                        welcomeDescription: result.welcomeDescription,
                        thumbImageURL: thumb,
                        largeImageURL: large,
                        isLiked: result.isLiked ?? false
                    )
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: mapped)
                    self.lastLoadedPage = nextPage
                    self.isLoading = false
                    self.task = nil
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: [RequestError] request=\(request) error=\(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.task = nil
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private helpers
    
    private func makePhotosRequest(page: Int, perPage: Int) -> URLRequest? {
        guard var baseURL = Constants.defaultBaseURL else { return nil }
        baseURL.append(path: "photos")
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
