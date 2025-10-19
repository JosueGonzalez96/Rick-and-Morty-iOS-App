//
//  CharacterModel.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
struct CharacterModel: Decodable, Identifiable {
    let id: Int
    let title: String
    let detail: String
}
