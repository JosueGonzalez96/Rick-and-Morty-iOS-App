//
//  APIService.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
import Alamofire
internal import Combine

final class APIService: APIServiceProtocol {
    private let baseURL = "https://rickandmortyapi.com/api/character"

    func fetchItems(page: Int) -> AnyPublisher<CharacterResponse, Error> {
        Deferred {
            Future { promise in
                Task.detached {
                    do {
                        let items = try await self.fetchItemsManualDecode(page: page)
                        promise(.success(items))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func fetchItemsManualDecode(page: Int) async throws -> CharacterResponse {
        let parameters: [String: Any] = ["page": page]

        return try await withCheckedThrowingContinuation { continuation in
            AF.request(baseURL, parameters: parameters)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let decoder = JSONDecoder()
                            let decoded = try decoder.decode(CharacterResponse.self, from: data)
                            continuation.resume(returning: decoded)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
