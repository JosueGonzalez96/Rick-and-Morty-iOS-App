//
//  CharactersSheetViewController.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import UIKit
internal import Combine

final class CharactersSheetViewController: UITableViewController, UISearchResultsUpdating {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var cancellables = Set<AnyCancellable>()

    var onSelectCharacter: ((CharacterRM) -> Void)?
    private var viewModel: MapVM
    
    init(viewModel: MapVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Personajes"
        tableView.register(CharacterCell.self, forCellReuseIdentifier: "CharacterCell")
        setupSearch()
        bindViewModel()
        viewModel.fetchCharacters()
    }

    private func setupSearch() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar personaje"
        definesPresentationContext = true
    }

    private func bindViewModel() {
        viewModel.$filteredCharacters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msg in
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }

    // MARK: - Search
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.filterCharacters(searchText: searchController.searchBar.text ?? "")
    }

    // MARK: - Table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredCharacters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as? CharacterCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.filteredCharacters[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let character = viewModel.filteredCharacters[indexPath.row]
        onSelectCharacter?(character)
        dismiss(animated: true)
    }
}
