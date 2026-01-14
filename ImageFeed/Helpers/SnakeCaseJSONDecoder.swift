//
//  SnakeCaseJSONDecoder.swift
//  ImageFeed
//
//  Created by Павел Кузнецов on 07.01.2026.
//
import Foundation


public extension JSONDecoder {
    nonisolated static func snakeCase() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
