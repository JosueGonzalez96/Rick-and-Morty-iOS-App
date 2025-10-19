//
//  MapVCTests.swift
//  ChallengeRMTests
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation

import XCTest
internal import MapKit
@testable import ChallengeRM

final class MapVCTests: XCTestCase {

    final class MapVMMock: MapVM { }

    var sut: MapVC!
    var mockVM: MapVMMock!

    override func setUp() {
        super.setUp()
        let service = APIService()
        mockVM = MapVMMock(service: service)
        sut = MapVC(viewModel: mockVM)
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        mockVM = nil
        super.tearDown()
    }

    func test_viewDidLoad_setsTitleAndSubviews() {
        // THEN
        XCTAssertEqual(sut.title, "Mapa")
        XCTAssertTrue(sut.view.subviews.contains(where: { $0 is MKMapView }))
        XCTAssertTrue(sut.view.subviews.contains(where: { $0 is UIButton }))
    }

    func test_mapView_hasCorrectDelegate() {
        XCTAssertTrue(sut.mapView.delegate === sut)
    }

    func test_showButton_isConfiguredCorrectly() {
        let button = sut.view.subviews.compactMap({ $0 as? UIButton }).first
        XCTAssertEqual(button?.title(for: .normal), "Mostrar personajes")
        XCTAssertEqual(button?.backgroundColor, .systemBlue)
    }

    func test_addCharacterAnnotation_addsSingleAnnotation() {
        // GIVEN
        let coordinate = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        let character = CharacterRM(
            id: 1,
            name: "Rick",
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: .init(name: "Earth", url: ""),
            location: .init(name: "Citadel", url: ""),
            image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            episode: [],
            url: "",
            created: "",
            isFavorite: false
        )

        sut.addCharacterAnnotation(character: character, coordinate: coordinate)

        XCTAssertEqual(sut.mapView.annotations.count, 1)
        let annotation = sut.mapView.annotations.first as? CharacterAnnotation
        XCTAssertEqual(annotation?.coordinate.latitude, coordinate.latitude)
        XCTAssertEqual(annotation?.character.name, "Rick")
    }

    func test_showSheet_presentsSheetController() {
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()

        sut.showSheet()

        XCTAssertTrue(sut.presentedViewController is UINavigationController)
        let nav = sut.presentedViewController as? UINavigationController
        XCTAssertTrue(nav?.topViewController is CharactersSheetViewController)
    }

    func test_centerMap_setsRegionAndAnnotation() {
        let character = CharacterRM(
            id: 2,
            name: "Morty",
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: .init(name: "Earth", url: ""),
            location: .init(name: "Citadel", url: ""),
            image: "",
            episode: [],
            url: "",
            created: "",
            isFavorite: false
        )

        sut.centerMap(for: character)

        XCTAssertEqual(sut.mapView.annotations.count, 1)
        let region = sut.mapView.region
        XCTAssertNotEqual(region.center.latitude, 0)
        XCTAssertNotEqual(region.center.longitude, 0)
    }

    func test_mapView_viewForAnnotation_returnsAnnotationView() {
        let character = CharacterRM(
            id: 3,
            name: "Summer",
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Female",
            origin: .init(name: "Earth", url: ""),
            location: .init(name: "Citadel", url: ""),
            image: "https://rickandmortyapi.com/api/character/avatar/3.jpeg",
            episode: [],
            url: "",
            created: "",
            isFavorite: false
        )
        let annotation = CharacterAnnotation(character: character,
                                             coordinate: CLLocationCoordinate2D(latitude: 5, longitude: 5))

        let view = sut.mapView(sut.mapView, viewFor: annotation)

        XCTAssertNotNil(view)
        XCTAssertEqual(view?.canShowCallout, true)
    }

    // MARK: - Image Resizing

    func test_resizeImage_returnsCorrectSize() {
        let image = UIImage(systemName: "person.fill")!
        let targetSize = CGSize(width: 40, height: 40)

        let resized = sut.resizeImage(image: image, targetSize: targetSize)

        XCTAssertEqual(resized.size.width, targetSize.width, accuracy: 0.5)
        XCTAssertEqual(resized.size.height, targetSize.height, accuracy: 0.5)
    }
}
