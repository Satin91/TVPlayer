//
//  TVChannelCell.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

final class TVChannelCell: UITableViewCell {
    
    private let channelImage = UIImageView()
    private let channelNameLabel = UILabel()
    private let currentBroadcastLabel = UILabel()
    private let labelsStackView = UIStackView()
    private let favoriteButton = UIButton()
    
    var onTapFavoriteButton: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        makeConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearReusableImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureCell(with channel: TVChannel) {
        channelNameLabel.text = channel.name
        currentBroadcastLabel.text = channel.currentBroadcast.title
        favoriteButton.imageView?.tintColor = channel.isFavorite ? Theme.Colors.accent : Theme.Colors.lightGray
        channelImage.loadImage(from: channel.imageURL)
    }
    
    private func setupView() {
        contentView.addSubview(channelImage)
        contentView.addSubview(channelNameLabel)
        contentView.addSubview(labelsStackView)
        contentView.addSubview(favoriteButton)
        contentView.backgroundColor = Theme.Colors.gray
        contentView.layer.cornerRadius = 10
        
        backgroundColor = .clear
        selectionStyle = .none
        
        labelsStackView.addArrangedSubview(channelNameLabel)
        labelsStackView.addArrangedSubview(currentBroadcastLabel)
        labelsStackView.alignment = .leading
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 8
        
        
        favoriteButton.setImage(Theme.Images.star.withRenderingMode(.alwaysTemplate), for: .normal)
        favoriteButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        
        favoriteButton.addTarget(self, action: #selector(tapFavorite(_:)), for: .touchUpInside)
        
        channelImage.backgroundColor = .white
        channelImage.layer.cornerRadius = 12
        
        channelNameLabel.textColor = .white
        
        currentBroadcastLabel.textColor = .white
    }
    
    @objc private func tapFavorite(_ button: UIButton) {
        self.onTapFavoriteButton?()
    }

    private func makeConstraints() {
        channelImage.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            channelImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            channelImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            channelImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            channelImage.widthAnchor.constraint(equalTo: channelImage.heightAnchor),
            
            labelsStackView.leadingAnchor.constraint(equalTo: channelImage.trailingAnchor, constant: 16),
            labelsStackView.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            labelsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    private func clearReusableImage() {
        channelImage.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
    }
    
}
