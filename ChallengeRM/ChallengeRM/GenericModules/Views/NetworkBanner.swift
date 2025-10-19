//
//  NetworkBanner.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import UIKit

final class NetworkBanner: UIView {
    private let label = UILabel()
    private var topConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .systemRed
        layer.cornerRadius = 0
        clipsToBounds = true

        label.text = "Sin conexión a internet"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func show(in window: UIWindow?) {
        guard let window = window else { return }

        if superview != nil { return }

        translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(self)

        let guide = window.safeAreaLayoutGuide
        topConstraint = topAnchor.constraint(equalTo: guide.topAnchor, constant: -44)

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: window.leadingAnchor),
            trailingAnchor.constraint(equalTo: window.trailingAnchor),
            heightAnchor.constraint(equalToConstant: 44),
            topConstraint!
        ])

        window.layoutIfNeeded()

        UIView.animate(withDuration: 0.4) {
            self.topConstraint?.constant = 0
            window.layoutIfNeeded()
        }
    }

    func hide() {
        guard superview != nil else { return }
        guard let window = superview as? UIWindow else { return }

        UIView.animate(withDuration: 0.4, animations: {
            self.topConstraint?.constant = -100
            window.layoutIfNeeded()
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}
