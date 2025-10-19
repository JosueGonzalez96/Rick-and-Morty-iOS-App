//
//  DetailCharacterVC.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import UIKit
internal import Combine
import SwiftUI

final class DetailCharacterVC: UIViewController {
    private let viewModel: DetailCharacterVM
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: DetailCharacterVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
  
    private func setupUI() {
        title = viewModel.item.name
        self.navigationController?.title = "Personajes"
        view.backgroundColor = .systemBackground
        let vistaSwiftUI = ViewDetail(viewModel: self.viewModel)
        
        let hostingController = UIHostingController(rootView: vistaSwiftUI)
        
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        NSLayoutConstraint.activate([
            hostingController.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)

        ])

    }
}

