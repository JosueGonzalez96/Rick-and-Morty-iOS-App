//
//  FavoritesVC.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
import UIKit
internal import Combine
import LocalAuthentication

class FavoritesVC: UIViewController {
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let viewModel: FavoritesVM
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: FavoritesVM) {
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = true
        viewModel.send(.authenticateUser)
    }
    
    
    private func showAuthFailedAlert() {
        let alert = UIAlertController(title: "Autenticación requerida",
                                      message: viewModel.showAuthFailedAlert,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Intentar de nuevo", style: .default) { [weak self] _ in
            self?.viewModel.send(.authenticateUser)
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 0 // por ejemplo, vuelve al primer tab
        })
        present(alert, animated: true)
    }
    
    private func setupUI() {
        self.navigationController?.title = "Favoritos"
        
        title = "Favoritos"
        view.backgroundColor = .systemBackground
        
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
    }
    @objc private func refreshTapped() {
        viewModel.send(.refresh)
    }
    private func bindViewModel() {
        viewModel.$characters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.isHidden = false
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.navigationItem.rightBarButtonItem?.isEnabled = !loading
                if loading {
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
        
        viewModel.$showAuthFailedAlert
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msg in
                self?.showAuthFailedAlert()
            }
            .store(in: &cancellables)
    }
    private func presentError(_ message: String) {
        let a = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

extension FavoritesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.characters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCell", for: indexPath) as? CharacterCell
        let item = viewModel.characters[indexPath.row]
        cell?.configure(with: item)
        return cell ?? UITableViewCell()
    }
}

extension FavoritesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
           let favoriteAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completionHandler in
               guard let self = self else { return }

               self.viewModel.send(.delete(indexPath.row))
               
               tableView.deleteRows(at: [indexPath], with: .fade)
               completionHandler(true)
           }
           
           favoriteAction.image = UIImage(systemName: "heart.fill")
           favoriteAction.backgroundColor = .systemPink
           
           let configuration = UISwipeActionsConfiguration(actions: [favoriteAction])
           configuration.performsFirstActionWithFullSwipe = false 
           
           return configuration
    }
}
