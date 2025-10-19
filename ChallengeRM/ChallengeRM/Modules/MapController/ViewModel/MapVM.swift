//
//  MapVM.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
internal import Combine
class MapVM: ObservableObject {
    private let service: APIServiceProtocol

    @Published var characters: [CharacterRM] = []
    @Published var filteredCharacters: [CharacterRM] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    init(service: APIServiceProtocol) {
        self.service = service
    }
    func fetchCharacters() {
        guard let url = URL(string: "https://rickandmortyapi.com/api/character") else { return }

        isLoading = true

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CharacterResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                self?.characters = response.results
                self?.filteredCharacters = response.results
            }
            .store(in: &cancellables)
    }

    func filterCharacters(searchText: String) {
        guard !searchText.isEmpty else {
            filteredCharacters = characters
            return
        }
        filteredCharacters = characters.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
}
