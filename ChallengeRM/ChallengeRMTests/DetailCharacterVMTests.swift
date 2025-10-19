//
//  DetailCharacterVMTests.swift
//  ChallengeRMTests
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
import XCTest
import CoreData
import Combine
import CoreLocation
@testable import ChallengeRM
internal import MapKit

final class DetailCharacterVMTests: XCTestCase {

    private var sut: DetailCharacterVM!
    private var context: NSManagedObjectContext!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        context = PersistenceMock.makeInMemoryContext()
        cancellables = []

        let character = CharacterRM(
            id: 1,
            name: "Rick Sanchez",
            status: "Alive",
            species: "Human",
            type: "Scientist",
            gender: "Male",
            origin: CharacterLocationModel(name: "Earth", url: "https://api.com/origin/1"),
            location: CharacterLocationModel(name: "Citadel", url: "https://api.com/location/1"),
            image: "https://rick.com/image.png",
            episode: ["https://api.com/episode/1"],
            url: "https://api.com/character/1",
            created: "2023-01-01T00:00:00Z",
            isFavorite: true
        )

        sut = DetailCharacterVM(item: character, context: context)
    }

    override func tearDown() {
        sut = nil
        context = nil
        cancellables = nil
        super.tearDown()
    }

    func test_init_setsInitialValues() {
        XCTAssertEqual(sut.item.name, "Rick Sanchez")
        XCTAssertNotNil(sut.pinLocation)
        XCTAssertNotNil(sut.region.center)
        XCTAssertFalse(sut.isFavorite)
        XCTAssertNil(sut.errorMessage)
    }

    func test_saveFavorite_persistsCharacterInCoreData() throws {
        XCTAssertFalse(sut.isFavorite)

        sut.isFavorite = true
        sut.updateFavorite()

        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Character")
        let results = try context.fetch(fetch)
        XCTAssertEqual(results.count, 1)

        let stored = results.first
        XCTAssertEqual(stored?.value(forKey: "name") as? String, "Rick Sanchez")
        XCTAssertEqual(stored?.value(forKey: "isFavorite") as? Bool, true)
    }

    func test_updateFavorite_updatesExistingRecord() throws {
        sut.isFavorite = true
        sut.updateFavorite()

        sut.isFavorite = false
        sut.updateFavorite()

        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Character")
        let results = try context.fetch(fetch)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.value(forKey: "isFavorite") as? Bool, false)
    }

    func test_getFavorite_loadsExistingFavorite() throws {
        let entity = NSEntityDescription.entity(forEntityName: "Character", in: context)!
        let character = NSManagedObject(entity: entity, insertInto: context)
        character.setValue(1, forKey: "id")
        character.setValue(true, forKey: "isFavorite")
        try context.save()

        // When
        let characterRM = CharacterRM(
            id: 1,
            name: "Rick",
            status: "Alive",
            species: "Human",
            type: "Scientist",
            gender: "Male",
            origin: CharacterLocationModel(name: "", url: ""),
            location: CharacterLocationModel(name: "", url: ""),
            image: "",
            episode: [],
            url: "",
            created: "",
            isFavorite: true
        )
        let vm = DetailCharacterVM(item: characterRM, context: context)

        XCTAssertTrue(vm.isFavorite)
    }

    func test_generarCoordenadasAleatorias_returnsValidCoordinates() {
        let coord = sut.pinLocation
        XCTAssert(coord.latitude >= -90 && coord.latitude <= 90)
        XCTAssert(coord.longitude >= -180 && coord.longitude <= 180)
    }

    func test_getAllEpisodes_setsErrorMessageOnFailure() async {
        let invalidCharacter = CharacterRM(
            id: 2,
            name: "Morty",
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: CharacterLocationModel(name: "", url: ""),
            location: CharacterLocationModel(name: "", url: ""),
            image: "",
            episode: ["invalid_url"],
            url: "",
            created: "",
            isFavorite: true
        )

        let vm = DetailCharacterVM(item: invalidCharacter, context: context)
        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertNotNil(vm.errorMessage)
    }
}

// MARK: - Mock Persistence

enum PersistenceMock {
    static func makeInMemoryContext() -> NSManagedObjectContext {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "Character"
        entity.managedObjectClassName = "NSManagedObject"

        var properties: [NSAttributeDescription] = []
        let attributes: [String: NSAttributeType] = [
            "id": .integer64AttributeType,
            "name": .stringAttributeType,
            "status": .stringAttributeType,
            "species": .stringAttributeType,
            "type": .stringAttributeType,
            "gender": .stringAttributeType,
            "locationOriginName": .stringAttributeType,
            "locationOriginUrl": .stringAttributeType,
            "currentLocationName": .stringAttributeType,
            "currentLocationUrl": .stringAttributeType,
            "image": .stringAttributeType,
            "isFavorite": .booleanAttributeType,
            "episode": .transformableAttributeType,
            "url": .stringAttributeType,
            "created": .stringAttributeType
        ]

        for (key, type) in attributes {
            let attr = NSAttributeDescription()
            attr.name = key
            attr.attributeType = type
            properties.append(attr)
        }

        entity.properties = properties
        model.entities = [entity]

        let container = NSPersistentContainer(name: "InMemory", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading in-memory store: \(error)")
            }
        }

        return container.viewContext
    }
}
