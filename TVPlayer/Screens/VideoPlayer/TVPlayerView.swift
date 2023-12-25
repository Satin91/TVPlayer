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
    func playerTapped()
}

final class TVPlayerView: UIView {
    
    enum Constants {
        static let topContainerHeight: CGFloat = 44
        static let topPadding: CGFloat = 12
        static let bottomPadding: CGFloat = 12
        static let smallPadding: CGFloat = 10
        static let mediumPadding: CGFloat = 16
        static let largePadding: CGFloat = 24
        static let playImageSide: CGFloat = 120
    }
    
    let testVideoURL = URL(string: "https://tv-trt1.medya.trt.com.tr/master_480.m3u8")
    
    // top on view
    var topContainer = UIView()
    let backButton = UIButton()
    let channelImage = UIImageView()
    var broadcastLabel = UILabel()
    var channelNameLabel = UILabel()
    let topLabelsStackView = UIStackView()
    let playImageView = UIImageView()
    
    // bottom on view
    var bottomContainer = UIView()
    var timeline = Slider()
    
    var playerState: Observable<TVPlayerModel.PlayerState> = .init(.pause)
    
    weak var actionsDelegate: TVPlayerViewActionsDelegate?
    
    var topContainerConstraint = NSLayoutConstraint()
    var bottomContainerConstraint = NSLayoutConstraint()
    
    var videoPlayer = VideoPlayer()
    
    var channel: TVChannel?
    
    var timer: Timer?
    
    
    
    func configure(with channel: TVChannel) {
        self.channel = channel
        channelImage.loadImage(from: channel.imageURL)
        channelNameLabel.text = channel.name
        broadcastLabel.text = channel.currentBroadcast.title
        videoPlayer.configure(with: testVideoURL)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        makeConstraints()
        subscribe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func subscribe() {
        playerState.subscribe { [unowned self] playerState in
            switch playerState {
            case .loading:
                pauseState()
            case .playing:
                playingState()
            case .pause:
                pauseState()
            case .stop:
                stopState()
            }
        }
    }
    
    private func setupView() {
        addSubview(videoPlayer)
        addSubview(topContainer)
        addSubview(bottomContainer)
        addSubview(playImageView)
        
        
        // Top
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
        
        // Bottom
        bottomContainer.addSubview(timeline)
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(playerTapped(_:)))
        videoPlayer.addGestureRecognizer(gesture)
        
        playImageView.image = Theme.Images.play
        playImageView.layer.opacity = 0
        
        backgroundColor = Theme.Colors.darkGray
    }
    
    private func playingState() {
        hideImageWithAnimate()
//        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
//            self.hideTopContainer()
//        }
        videoPlayer.playVideo()
    }
    
    private func pauseState() {
//        timer?.invalidate()
//        showTopContainer()
        showImageWithAnimate()
        videoPlayer.pauseVideo()
    }
    
    private func stopState() {
        playImageView.isHidden = true
        videoPlayer.pauseVideo()
    }
    
    @objc private func playerTapped(_ gesture: UITapGestureRecognizer) {
        actionsDelegate?.playerTapped()
    }
    
    @objc private func backButtonTapped(_ button: UIButton) {
        actionsDelegate?.navigationBackButtonTap()
    }
    
    private func hideTopContainer() {
        self.topContainerConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.topContainer.layer.opacity = 0
            self.layoutIfNeeded()
        }
    }
    
    private func showTopContainer() {
        self.topContainerConstraint.constant = Constants.topPadding
        UIView.animate(withDuration: 0.3) {
            self.topContainer.layer.opacity = 1
            self.layoutIfNeeded()
        }
    }
    
    private func hideImageWithAnimate() {
        UIView.animate(withDuration: 0.05) {
            self.playImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.playImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.playImageView.layer.opacity = 0
            }
        }

    }
    
    private func showImageWithAnimate() {
        playImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4, delay: .zero, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8) {
            self.playImageView.layer.opacity = 1
            self.playImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    
    private func makeConstraints() {
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        channelImage.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        topLabelsStackView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.translatesAutoresizingMaskIntoConstraints = false
        playImageView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        timeline.translatesAutoresizingMaskIntoConstraints = false
        
        topContainerConstraint = topContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topPadding)
        bottomContainerConstraint = bottomContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomPadding)
        
        NSLayoutConstraint.activate([
            // Top container
            topContainerConstraint,
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
            
            // PlayImage
            playImageView.widthAnchor.constraint(equalToConstant: Constants.playImageSide),
            playImageView.heightAnchor.constraint(equalTo: playImageView.widthAnchor),
            playImageView.centerXAnchor.constraint(equalTo: videoPlayer.centerXAnchor),
            playImageView.centerYAnchor.constraint(equalTo: videoPlayer.centerYAnchor),
            
            // Bottom container
            bottomContainerConstraint,
            bottomContainer.heightAnchor.constraint(equalToConstant: 44),
            bottomContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.mediumPadding),
            bottomContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.mediumPadding),
            
            timeline.heightAnchor.constraint(equalToConstant: 18),
            timeline.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor),
            timeline.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            timeline.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
        ])
    }
}
