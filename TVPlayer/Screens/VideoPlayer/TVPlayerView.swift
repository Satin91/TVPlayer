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
    func videoIsLoaded()
    func tapResolution(scale: String)
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
        
        static let timerHidingPanelValue: CGFloat = 2.0
        
        static let liveBroadcastText = "Прямой эфир"
    }
    
    let test2VideoURL = URL(string: "https://cdn.ntv.ru/ntv0_hd/tracks-v3a1/rewind-7150.m3u8")
    let testVideoURL = URL(string: "https://tv-trt1.medya.trt.com.tr/master_480.m3u8")
    
    // top on view
    let topContainer = UIView()
    let backButton = UIButton()
    let channelImage = UIImageView()
    let broadcastLabel = UILabel()
    let channelNameLabel = UILabel()
    let topLabelsStackView = UIStackView()
    let playImageView = UIImageView()
    
    // bottom on view
    let bottomContainer = UIView()
    let timeline = Slider()
    let timelineLabel = UILabel()
    let settingsButton = UIButton(type: .system)

    let resolutions = ["1080p", "720p", "480p", "AUTO"]
    let contextMenu = ContextMenu(elements: ["1080p","720p", "480p", "AUTO"])
    var playerState: Observable<TVPlayerModel.PlayerState> = .init(.pause)
    
    private var timerHidingPanel: Timer?
    private var isPanelVisible = Observable(true)
    private var isPlayButtonVisible = Observable(true)
    
    weak var actionsDelegate: TVPlayerViewActionsDelegate?
    
    private var topContainerConstraint = NSLayoutConstraint()
    private var bottomContainerConstraint = NSLayoutConstraint()
    
    private var videoPlayer = VideoPlayer()
    private let activityIndicator = UIActivityIndicatorView()
    
    var channel: TVChannel?
    
    
    func configure(with channel: TVChannel) {
        self.channel = channel
        channelImage.loadImage(from: channel.imageURL)
        channelNameLabel.text = channel.name
        broadcastLabel.text = channel.currentBroadcast.title
        videoPlayer.configure(with: channel.channelURL)
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
                loadingState()
            case .playing:
                playingState()
            case .pause:
                pauseState()
            case .stop:
                stopState()
            }
        }
        
        videoPlayer.currentTime.subscribe { seconds in
            self.timelineLabel.text = seconds > 0 ? "-" + seconds.stringSecondsFormat() : Constants.liveBroadcastText
        }
        
        isPanelVisible.subscribe { [unowned self] visible in
            visible ? showPanel() : hidePanel()
        }
        
        isPlayButtonVisible.subscribe { [unowned self] visible in
            visible ? showImageWithAnimate() : hideImageWithAnimate()
        }
        
        timeline.sliderDidMove { [weak self] _ in
            self?.timerHidingPanel?.invalidate()
        }
        
        timeline.sliderDidEndMove { [weak self] value in
            self?.videoPlayer.rewind(to: value)
        }
        
        videoPlayer.videoLoadingComplete { [weak self] in
            self?.actionsDelegate?.videoIsLoaded()
        }
        
        contextMenu.didTapElement { [weak self] elementIndex in
            let scale = self!.resolutions[elementIndex]
            self?.actionsDelegate?.tapResolution(scale: scale)
            self?.contextMenu.hide()
        }
    }
    
    private func loadingState() {
        activityIndicator.isHidden = false
        videoPlayer.isHidden = true
        videoPlayer.pauseVideo()
    }
    
    private func playingState() {
        videoPlayer.isHidden = false
        isPlayButtonVisible.send(false)
        activityIndicator.isHidden = true
        timerHidingPanel = Timer.scheduledTimer(withTimeInterval: Constants.timerHidingPanelValue, repeats: false) { timer in
            self.isPanelVisible.send(false)
        }
        videoPlayer.playVideo()
    }
    
    private func pauseState() {
        timerHidingPanel?.invalidate()
        showPanel()
        isPlayButtonVisible.send(true)
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
    
    @objc private func settingsButtonTapped(_ button: UIButton) {
        if contextMenu.layer.opacity == 0 {
            contextMenu.show()
        } else {
            contextMenu.hide()
        }
    }
    
    private func hidePanel(_ delay: CGFloat = 0) {
        self.topContainerConstraint.constant = 0
        self.bottomContainerConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.topContainer.layer.opacity = 0
            self.bottomContainer.layer.opacity = 0
            self.layoutIfNeeded()
        }
    }
    
    private func showPanel() {
        self.topContainerConstraint.constant = Constants.topPadding
        self.bottomContainerConstraint.constant = -Constants.bottomPadding
        UIView.animate(withDuration: 0.3) {
            self.topContainer.layer.opacity = 1
            self.bottomContainer.layer.opacity = 1
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
}

// MARK: - Setup view
extension TVPlayerView {
    private func setupView() {
        addSubview(videoPlayer)
        addSubview(activityIndicator)
        addSubview(topContainer)
        addSubview(bottomContainer)
        addSubview(playImageView)
        addSubview(contextMenu)
        // Top
        topContainer.addSubview(backButton)
        topContainer.addSubview(channelImage)
        topContainer.addSubview(topLabelsStackView)
        
        activityIndicator.startAnimating()
        
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
        bottomContainer.addSubview(timelineLabel)
        bottomContainer.addSubview(settingsButton)
        
        timelineLabel.font = .systemFont(ofSize: 14, weight: .regular)
        timelineLabel.textColor = .white
        timelineLabel.text = Constants.liveBroadcastText
        
        settingsButton.setImage(Theme.Images.settings, for: .normal)
        settingsButton.tintColor = .white
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped(_:)), for: .touchUpInside)
        
        contextMenu.layer.cornerRadius = 14
        contextMenu.clipsToBounds = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(playerTapped(_:)))
        videoPlayer.addGestureRecognizer(gesture)
        
        playImageView.image = Theme.Images.play
        playImageView.layer.opacity = 0
        
        backgroundColor = .black
    }
    
    private func makeConstraints() {
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        channelImage.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        topLabelsStackView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        playImageView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        timeline.translatesAutoresizingMaskIntoConstraints = false
        timelineLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        contextMenu.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            // Activity indicator
            activityIndicator.widthAnchor.constraint(equalToConstant: 44),
            activityIndicator.heightAnchor.constraint(equalTo: activityIndicator.widthAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // PlayImage
            playImageView.widthAnchor.constraint(equalToConstant: Constants.playImageSide),
            playImageView.heightAnchor.constraint(equalTo: playImageView.widthAnchor),
            playImageView.centerXAnchor.constraint(equalTo: videoPlayer.centerXAnchor),
            playImageView.centerYAnchor.constraint(equalTo: videoPlayer.centerYAnchor),
            
            // Bottom container
            bottomContainerConstraint,
            bottomContainer.heightAnchor.constraint(equalToConstant: 44),
            bottomContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.mediumPadding),
            bottomContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.mediumPadding),
            
            // Tmeline
            timeline.heightAnchor.constraint(equalToConstant: 4),
            timeline.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor),
            timeline.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            timeline.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            
            // Timeline label
            timelineLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor),
            timelineLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            timelineLabel.widthAnchor.constraint(equalTo: bottomContainer.widthAnchor),
            
            // Settings button
            settingsButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 24),
            settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
            
            contextMenu.bottomAnchor.constraint(equalTo: settingsButton.topAnchor, constant: -12),
            contextMenu.trailingAnchor.constraint(equalTo: settingsButton.trailingAnchor),
            contextMenu.heightAnchor.constraint(equalToConstant: 200),
            contextMenu.widthAnchor.constraint(equalToConstant: 128),
        ])
    }
}
