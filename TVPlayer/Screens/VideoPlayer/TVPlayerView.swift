//
//  TVPlayerView.swift
//  TVPlayer
//
//  Created by Артур Кулик on 24.12.2023.
//

import UIKit
import AVKit
import AVFoundation

protocol TVPlayerViewActionsDelegate: AnyObject {
    func navigationBackButtonTap()
}

final class TVPlayerView: UIView {
    
    enum Constants {
        static let topContainerHeight: CGFloat = 44
        static let topPadding: CGFloat = 12
        static let smallPadding: CGFloat = 10
        static let mediumPadding: CGFloat = 16
        static let largePadding: CGFloat = 24
    }
    
    let testVideoURL = URL(string: "https://tv-trt1.medya.trt.com.tr/master_480.m3u8")
    var topContainer = UIView()
    
    let backButton = UIButton()
    let channelImage = UIImageView()
    var broadcastLabel = UILabel()
    var channelNameLabel = UILabel()
    let topLabelsStackView = UIStackView()
    
    weak var actionsDelegate: TVPlayerViewActionsDelegate?
    
    var videoPlayer = VideoPlayer()
    
    var channel: TVChannel?
    
    func configure(with channel: TVChannel) {
        self.channel = channel
        self.channelImage.loadImage(from: channel.imageURL)
        self.channelNameLabel.text = channel.name
        self.broadcastLabel.text = channel.currentBroadcast.title
        videoPlayer.configure(with: testVideoURL)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(topContainer)
        addSubview(videoPlayer)
        
        topContainer.addSubview(backButton)
        topContainer.addSubview(channelImage)
        topContainer.addSubview(topLabelsStackView)
        
        topLabelsStackView.addArrangedSubview(broadcastLabel)
        topLabelsStackView.addArrangedSubview(channelNameLabel)
        topLabelsStackView.axis = .vertical
        topLabelsStackView.alignment = .leading
        
        broadcastLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        broadcastLabel.textColor = .white
        
        channelNameLabel.font = .systemFont(ofSize: 16, weight: .regular)
        channelNameLabel.textColor = .white.withAlphaComponent(0.8)
        
        backButton.setImage(Theme.Images.arrowLeft, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        
        backgroundColor = Theme.Colors.darkGray
    }
    
    func playVideo() {
        videoPlayer.playVideo()
    }
    
    @objc private func backButtonTapped(_ button: UIButton) {
        actionsDelegate?.navigationBackButtonTap()
    }
    
    private func makeConstraints() {
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        channelImage.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        topLabelsStackView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Top container
            topContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topPadding),
            topContainer.heightAnchor.constraint(equalToConstant: Constants.topContainerHeight),
            topContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.smallPadding),
            topContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.smallPadding),
            
            // Back button
            backButton.topAnchor.constraint(equalTo: topContainer.topAnchor),
            backButton.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor),
            backButton.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor),
            
            // Channel image
            channelImage.topAnchor.constraint(equalTo: topContainer.topAnchor),
            channelImage.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor),
            channelImage.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: Constants.smallPadding),
            channelImage.widthAnchor.constraint(equalTo: channelImage.heightAnchor),
            
            // Labels stack view
            topLabelsStackView.topAnchor.constraint(equalTo: topContainer.topAnchor),
            topLabelsStackView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor),
            topLabelsStackView.leadingAnchor.constraint(equalTo: channelImage.trailingAnchor, constant: Constants.largePadding),
            topLabelsStackView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            
            // Video player
            videoPlayer.topAnchor.constraint(equalTo: topAnchor),
            videoPlayer.leadingAnchor.constraint(equalTo: leadingAnchor),
            videoPlayer.trailingAnchor.constraint(equalTo: trailingAnchor),
            videoPlayer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
    }
}
