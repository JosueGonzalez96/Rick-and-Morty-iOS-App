//
//  ListVC.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
import UIKit
internal import Combine
internal import CoreData

final class ListVC: UIViewController {
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let viewModel: ListVM
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ListVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        self.navigationItem.title = "Filtrado por \(viewModel.typeFilter.rawValue)"

//        title = "Filtrado por nombre"
//        self.navigationController?.title = "Personajes"

        view.backgroundColor = .systemBackground

        searchController.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CharacterCell.self, forCellReuseIdentifier: "CharacterCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar items..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        setButtonsNavBar()
    }
    private func setButtonsNavBar() {
        let status = UIAction(title: "Estado", image: UIImage(systemName: "theatermasks")) { [weak self] _ in
            self?.viewModel.send(.filter(.status))
        }

        let name = UIAction(title: "Nombre", image: UIImage(systemName: "character.book.closed")) { [weak self] _ in
            self?.viewModel.send(.filter(.name))
        }

        let species = UIAction(title: "Especie", image: UIImage(systemName: "ladybug")) { [weak self] _ in
            self?.viewModel.send(.filter(.species))
        }

        let menu = UIMenu(title: "Filtrar por", children: [status, species, name])

        let menuButton = UIBarButtonItem(
            title: nil,
            image: UIImage(systemName: "ellipsis.circle"),
            primaryAction: nil,
            menu: menu
        )
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                            target: self,
                                                            action: #selector(refreshTapped))
        
    }
    @objc private func refreshTapped() {
        viewModel.send(.refresh)
    }
    
    private func bindViewModel() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                print("se actualizo el arreglo")
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.navigationItem.rightBarButtonItem?.isEnabled = !loading
                if loading {
                    // optionally show activity indicator
                    self?.navigationItem.titleView = UIActivityIndicatorView(style: .medium)
                    (self?.navigationItem.titleView as? UIActivityIndicatorView)?.startAnimating()
                } else {
                    self?.navigationItem.titleView = nil
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msg in
                self?.presentError(msg)
            }
            .store(in: &cancellables)
        
        viewModel.$typeFilter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationItem.title = "Filtrado por \(self?.viewModel.typeFilter.rawValue ?? "")"

            }
            .store(in: &cancellables)
    }

    private func presentError(_ message: String) {
        let a = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
extension ListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as? CharacterCell
        let item = viewModel.items[indexPath.row]
        cell?.configure(with: item)
        return cell ?? UITableViewCell()
    }
}
extension ListVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height * 1.5 {
            viewModel.send(.loadNextPage)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenterDetail(index: indexPath.row)
    }
    func presenterDetail(index: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let item = viewModel.items[index]
        let vm = DetailCharacterVM(item: item, context: context)
        let vc = DetailCharacterVC(viewModel: vm)
        show(vc, sender: nil)
    }
}

extension ListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.send(.search(query))
        self.tableView.reloadData()
    }
    
}
extension ListVC: UISearchControllerDelegate {
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        viewModel.send(.search(""))
        searchController.dismiss(animated: true)
    }
}
