//
//  ListViewModel.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
private import Combine

final class ListVM {
    // Inputs
    enum Input {
        case refresh
        case loadNextPage
        case search(String)
        case filter(Filters)
    }
    enum Filters: String {
        case name = "Nombre"
        case status = "Estado"
        case species = "Especie"
        case none = "ninguno"
    }
    private(set) var model: CharacterResponse?
    private var query: String = ""
    // Outputs
    @Published private(set) var items: [CharacterRM] = []
    @Published private(set) var allItems: [CharacterRM] = []
    @Published private(set) var filters: [String] = []

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var hasMorePages: Bool = true
    @Published private(set) var typeFilter: Filters = .name
    

    

    private let service: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    private var currentPage = 1
    private let itemsPerPage = 20
    

    init(service: APIServiceProtocol) {
        self.service = service
        load(page: 1)
    }

    func send(_ input: Input) {
        switch input {
        case .refresh:
            refresh()
        case .loadNextPage:
            loadNextPage()
        case .search(let query):
            filter(query: query)
        case .filter(let filter):
            filterBy(query: filter)
        }
    }
    private func filterBy(query: Filters) {
        self.typeFilter = query
    }
    private func filter(query: String) {
        items = allItems
        self.query = query
        if !query.isEmpty {
            switch typeFilter {
            case .name:
                items = items.filter({ return $0.name.lowercased().contains(query.lowercased()) })
            case .status:
                items = items.filter({ return $0.status.lowercased().contains(query.lowercased()) })
            case .species:
                items = items.filter({ return $0.species.lowercased().contains(query.lowercased()) })
            case .none:
                items = items.filter({ return $0.name.lowercased().contains(query.lowercased()) })

            }
        }
    }
    private func refresh() {
        currentPage = 1
        hasMorePages = true
        items = []
        load(page: currentPage)
    }

    private func loadNextPage() {
        guard !isLoading, hasMorePages else { return }
        currentPage += 1
        load(page: currentPage)
    }

    private func load(page: Int) {
        isLoading = true

        service.fetchItems(page: page)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false

                switch completion {
                case .finished: break
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }, receiveValue: { [weak self] responseModel in
                guard let self = self else { return }
                self.hasMorePages = responseModel.info.next != nil
                self.model = responseModel
                if page == 1 {
                    self.allItems = responseModel.results
                } else {
                    self.allItems.append(contentsOf: responseModel.results)
                }
                items = allItems
                if !query.isEmpty {
                    filterBy(query: typeFilter)
                }
            })
            .store(in: &cancellables)
    }
   
}
