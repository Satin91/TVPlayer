//
//  TVChannelCell.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

class TVChannelCell: UITableViewCell {
    
    private let channelNameLabel = UILabel()
    private let currentBroadcastLabel = UILabel()
    private let channelImage = UIImageView()
    private let labelsStackView = UIStackView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupChannelImage()
        setupStackView()
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
        channelImage.loadImage(from: channel.imageURL)
    }
    
    private func setupView() {
        contentView.addSubview(channelImage)
        contentView.addSubview(channelNameLabel)
        contentView.addSubview(labelsStackView)
        contentView.backgroundColor = Theme.Colors.gray
        contentView.layer.cornerRadius = 10
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func setupStackView() {
        labelsStackView.addArrangedSubview(channelNameLabel)
        labelsStackView.addArrangedSubview(currentBroadcastLabel)
        labelsStackView.alignment = .leading
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 8
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelsStackView.leadingAnchor.constraint(equalTo: channelImage.trailingAnchor, constant: 16),
            labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        channelNameLabel.textColor = .white
        currentBroadcastLabel.textColor = .white
    }
    
    private func setupChannelImage() {
        channelImage.translatesAutoresizingMaskIntoConstraints = false
        channelImage.backgroundColor = .white
        channelImage.layer.cornerRadius = 12
        NSLayoutConstraint.activate([
            channelImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            channelImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            channelImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            channelImage.widthAnchor.constraint(equalTo: channelImage.heightAnchor)
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
