//
//  CharacterAnnotation.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
import MapKit

class CharacterAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let character: CharacterRM
    var title: String? { character.name }

    init(character: CharacterRM, coordinate: CLLocationCoordinate2D) {
        self.character = character
        self.coordinate = coordinate
    }
}
