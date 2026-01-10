//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 07.01.2026.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}

    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
       
    func fetchProfileImage(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            let error = NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])
            print("[ProfileImageService.fetchProfileImage]: [AuthorizationError] username=\(username)")
            completion(.failure(error))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[ProfileImageService.fetchProfileImage]: [BadURL] username=\(username)")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let result):
                guard let self = self else { return }
                
                guard let urlString = result.profileImage?.small, !urlString.isEmpty else {
                    let error = NSError(domain: "ProfileImageService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Avatar URL not found"])
                    print("[ProfileImageService.fetchProfileImage]: [NotFound] username=\(username) request=\(request)")
                    completion(.failure(error))
                    return
                }
                
                self.avatarURL = urlString
                completion(.success(urlString))

                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": self.avatarURL ?? ""]
                    )

            case .failure(let error):
                print("[ProfileImageService.fetchProfileImage]: [RequestError] username=\(username) request=\(request) error=\(error)")
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
