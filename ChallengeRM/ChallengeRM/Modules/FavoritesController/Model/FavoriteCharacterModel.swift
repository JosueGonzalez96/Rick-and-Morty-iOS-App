//
//  FavoriteCharacterModel.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation

struct FavoriteCharacterModel: Identifiable {
    let id: Int
    let name: String
    let image: String
    let url: String
    let isFavorite: Bool
}
