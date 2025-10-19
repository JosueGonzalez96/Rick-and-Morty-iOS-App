//
//  APIServiceProtocol.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
internal import Combine

protocol APIServiceProtocol {
    func fetchItems(page: Int) -> AnyPublisher<CharacterResponse, Error>
}
