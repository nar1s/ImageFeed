//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 07.01.2026.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.fetchProfile]: [BadURL] token=\(token)")
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username ?? "",
                    firstName: profileResult.firstName ?? "",
                    lastName: profileResult.lastName ?? "",
                    bio: profileResult.bio ?? ""
                )
                self?.profile = profile
                completion(.success(profile))
                
            case .failure(let error):
                print("[ProfileService.fetchProfile]: [RequestError] request=\(request) error=\(error)")
                completion(.failure(error))
            }
            self?.task = nil
        }

        self.task = task
        task.resume()
    }
    
    func cleanProfile() {
        profile = nil
        if let task {
            task.cancel()
            self.task = nil
        }
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
