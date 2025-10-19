//
//  CharacterResponse.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation

@MainActor
struct CharacterResponse: Decodable, Sendable {
    let info: Info
    let results: [CharacterRM]
}

struct Info: Decodable, Sendable {
    let count, pages: Int
    let next: String?
    let prev: String?
}

struct CharacterRM: Decodable, Sendable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin, location: CharacterLocationModel
    let image: String
    let episode: [String]
    let url: String
    let created: String
    let isFavorite: Bool?
}

struct CharacterLocationModel: Decodable, Sendable {
    let name: String
    let url: String
}
