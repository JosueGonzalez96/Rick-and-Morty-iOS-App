//
//  MockAPIService.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

internal import Combine
import Foundation

final class APIServiceMock: APIServiceProtocol {
    var fetchItemsCalled = false
    var requestedPage: Int = 0
    var shouldFail = false
    var responseHasNext = true

    func fetchItems(page: Int) -> AnyPublisher<CharacterResponse, Error> {
        fetchItemsCalled = true
        requestedPage = page

        if shouldFail {
            return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error de red"]))
                .eraseToAnyPublisher()
        }

        let info = Info(count: 0, pages: 1, next: responseHasNext ? "https://api.com/page/2" : nil, prev: nil)
        let characters = [
            CharacterRM(id: 1, name: "Rick Sanchez", status: "Alive", species: "Human", type: "", gender: "", origin: CharacterLocationModel(name: "", url: ""), location: CharacterLocationModel(name: "", url: ""), image: "", episode: [], url: "", created: "", isFavorite: false)
        ]
        let response = CharacterResponse(info: info, results: characters)

        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
