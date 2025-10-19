//
//  CharacterCell.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import UIKit
import SDWebImage

class CharacterCell: UITableViewCell {
    private let characterImage = UIImageView()
    private let labelName = UILabel()
    private let labelStatus = UILabel()
    private let labelSpecies = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator

        // Configurar subviews
        characterImage.contentMode = .scaleAspectFit
        characterImage.tintColor = .systemBlue

        labelName.font = .systemFont(ofSize: 16, weight: .semibold)
        labelStatus.font = .systemFont(ofSize: 14)
        labelStatus.textColor = .secondaryLabel
        
        labelSpecies.font = .systemFont(ofSize: 14)
        labelSpecies.textColor = .secondaryLabel

        contentView.addSubview(characterImage)
        contentView.addSubview(labelName)
        contentView.addSubview(labelStatus)
        contentView.addSubview(labelSpecies)
    }

    private func setupConstraints() {
        characterImage.translatesAutoresizingMaskIntoConstraints = false
        labelName.translatesAutoresizingMaskIntoConstraints = false
        labelStatus.translatesAutoresizingMaskIntoConstraints = false
        labelSpecies.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            characterImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            characterImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            characterImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            characterImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            characterImage.widthAnchor.constraint(equalToConstant: 100),
            characterImage.heightAnchor.constraint(equalToConstant: 100),

            labelName.leadingAnchor.constraint(equalTo: characterImage.trailingAnchor, constant: 12),
            labelName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            labelStatus.leadingAnchor.constraint(equalTo: labelName.leadingAnchor),
            labelStatus.trailingAnchor.constraint(equalTo: labelName.trailingAnchor),
            labelStatus.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 2),
            
            labelSpecies.leadingAnchor.constraint(equalTo: labelStatus.leadingAnchor),
            labelSpecies.trailingAnchor.constraint(equalTo: labelStatus.trailingAnchor),
            labelSpecies.topAnchor.constraint(equalTo: labelStatus.bottomAnchor, constant: 2),
        ])
    }
    func configure(with model: CharacterRM) {
        characterImage.sd_setImage(with: URL(string: model.image), placeholderImage: UIImage(named: "placeholder"))
        labelName.text = model.name
        labelStatus.text = model.status
        labelSpecies.text = model.species

    }
    func configure(with model: FavoriteCharacterModel) {
        characterImage.sd_setImage(with: URL(string: model.image), placeholderImage: UIImage(named: "placeholder"))
        labelName.text = model.name
    }
}
