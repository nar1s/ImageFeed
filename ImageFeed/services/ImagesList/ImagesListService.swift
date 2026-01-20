//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 12.01.2026.
//

import Foundation
import CoreGraphics

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void)
}

final class ImagesListService: ImagesListServiceProtocol {
    
    static let shared = ImagesListService()
    private init() {}
    
    // MARK: - Properties
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    private var taskPageLoad: URLSessionTask?
    private var taskLike: URLSessionTask?
    private var isLoading = false
    private let perPage = 10
    
    // MARK: - Public methods
    
    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard !isLoading else { return }
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
                        let full = result.fullImageURL,
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
                        fullImageURL: full,
                        largeImageURL: large,
                        isLiked: result.isLiked ?? false
                    )
                }
                
                self.photos.append(contentsOf: mapped)
                self.lastLoadedPage = nextPage
                self.isLoading = false
                self.taskPageLoad = nil
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
                
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: [RequestError] request=\(request) error=\(error)")
                self.isLoading = false
                self.taskPageLoad = nil
            }
        }
        
        self.taskPageLoad = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        taskLike?.cancel()
        
        guard let request = makeChangeLikeRequest(photoId: photoId, isLike: isLike) else {
            print("[ImagesListService.changeLike]: [BadURL] photoId=\(photoId) isLike=\(isLike)")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikePhotoResponse, Error>) in
            guard let self else { return }
            switch result {
            case .success(let response):
                let serverLiked = response.photo?.likedByUser
                
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let current = self.photos[index]
                    let newIsLiked = serverLiked ?? (!current.isLiked)
                    let newPhoto = Photo(
                        id: current.id,
                        size: current.size,
                        createdAt: current.createdAt,
                        welcomeDescription: current.welcomeDescription,
                        fullImageURL: current.fullImageURL,
                        largeImageURL: current.largeImageURL,
                        isLiked: newIsLiked
                    )
                    self.photos[index] = newPhoto
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                self.taskLike = nil
                completion(.success(serverLiked ?? false))
                
            case .failure(let error):
                print("[ImagesListService.changeLike]: [RequestError] request=\(request) error=\(error)")
                self.taskLike = nil
                completion(.failure(error))
            }
        }
        
        self.taskLike = task
        task.resume()
    }
    
    func clearImagesList() {
        photos.removeAll()
        lastLoadedPage = nil
        if let task = taskPageLoad {
            task.cancel()
            taskPageLoad = nil
        }
        if let task = taskLike {
            task.cancel()
            taskLike = nil
        }
    }
    
    // MARK: - Private helpers
    
    private func makePhotosRequest(page: Int, perPage: Int) -> URLRequest? {
        var baseURL = Constants.defaultBaseURL
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
    
    private func makeChangeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        var baseURL = Constants.defaultBaseURL
        baseURL.append(path: "photos/\(photoId)/like")
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        
        guard let token = OAuth2TokenStorage.shared.token else {
            return nil
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

private struct LikePhotoResponse: Decodable {
    let photo: PhotoResult?
}

extension Notification.Name {
    static let imagesListServiceDidChange = Notification.Name("ImagesListService.didChangeNotification")
}
