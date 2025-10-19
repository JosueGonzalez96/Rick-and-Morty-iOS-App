//
//  ListVMTests.swift
//  ChallengeRMTests
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation

import XCTest
import Combine
@testable import ChallengeRM

final class ListVMTests: XCTestCase {

    private var sut: ListVM!
    private var serviceMock: APIServiceMock!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        serviceMock = APIServiceMock()
        sut = ListVM(service: serviceMock)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        serviceMock = nil
        cancellables = nil
        super.tearDown()
    }

    func test_init_loadsFirstPage() {
        XCTAssertTrue(serviceMock.fetchItemsCalled)
        XCTAssertEqual(serviceMock.requestedPage, 1)
    }

    func test_refresh_resetsPaginationAndLoadsFirstPage() {
        sut.send(.loadNextPage)
        XCTAssertEqual(serviceMock.requestedPage, 2)

        sut.send(.refresh)

        XCTAssertEqual(serviceMock.requestedPage, 1)
        XCTAssertTrue(sut.hasMorePages)
        XCTAssertTrue(sut.items.isEmpty == false)
    }

    func test_loadNextPage_incrementsPageNumber() {
        let initialPage = serviceMock.requestedPage

        sut.send(.loadNextPage)

        XCTAssertEqual(serviceMock.requestedPage, initialPage + 1)
    }

    func test_load_handlesErrorProperly() {
        serviceMock.shouldFail = true

        sut.send(.refresh)

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_hasMorePages_falseWhenNoNextPage() {
        serviceMock.responseHasNext = false

        sut.send(.refresh)

        XCTAssertFalse(sut.hasMorePages)
    }
}
