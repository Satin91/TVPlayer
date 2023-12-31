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
    func outsideTapped()
    func playButtonTapped()
    func pauseButtonTapped()
    func completeLoading(success: Bool)
    func tapResolution(scale: String)
}

final class TVPlayerView: UIView {
    
    enum Constants {
        static let topContainerHeight: CGFloat = 66
        static var bottomCcontainerHeight: CGFloat = 96
        static let padding: CGFloat = 12
        static let smallPadding: CGFloat = 10
        static let mediumPadding: CGFloat = 16
        static let largePadding: CGFloat = 24
        static let playButtonSide: CGFloat = 80
        
        static let timerHidingPanelValue: CGFloat = 3.0
        static let videoHeightRatio: CGFloat = 0.5625
        
        static let liveBroadcastText = "Прямой эфир"
        static let errorLabelText = "Невозможно воспроизвести трансляцию"
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
    let playButton = PlayButton()
    
    // bottom on view
    let bottomContainer = UIView()
    let timeline = Slider()
    let timelineLabel = UILabel()
    let settingsButton = UIButton(type: .system)

    let resolutions = ["1080p", "720p", "480p", "AUTO"]
    let contextMenu = ContextMenu(elements: ["1080p","720p", "480p", "AUTO"])
    
    var playerState: Observable<TVPlayerModel.PlayerActions> = .init(.stopPlayer)
    
    private var timerHidingPanel: Timer?
    private var isErrorVisible = Observable(true)
    private var isControlPanelVisible = Observable(true)
    private var isContextVisible = Observable(false)
    private var isVideoVisible = Observable(false)
    private var isIndicatorVisible = Observable(false)
    private var isPlayingVideo = Observable(true)
    
    weak var actionsDelegate: TVPlayerViewActionsDelegate?
    
    private var topContainerConstraint = NSLayoutConstraint()
    private var bottomContainerConstraint = NSLayoutConstraint()
    
    private var videoPlayer = VideoPlayer()
    private let activityIndicator = UIActivityIndicatorView()
    private let errorLabel = UILabel()
    
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
        externalActions()
        internalSubscribers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func externalActions() {
        playerState.subscribe { [unowned self] playerState in
            switch playerState {
            case .showError:
                showError()
            case .loadVideo:
                loadVideo()
            case .playVideo:
                playVideo()
            case .pauseVideo:
                pauseVideo()
            case .stopPlayer:
                stopPlayer()
            }
        }
        
        timeline.sliderDidMove { [weak self] _ in
            self?.timerHidingPanel?.fireDate = Date(timeIntervalSinceNow: Constants.timerHidingPanelValue)
        }
        
        timeline.sliderDidEndMove { [weak self] value in
            self?.videoPlayer.rewind(to: value)
        }
        
        videoPlayer.videoLoadingComplete { [weak self] success in
            self?.actionsDelegate?.completeLoading(success: success)
        }
        
        contextMenu.didTapElement { [weak self] elementIndex in
            let scale = self!.resolutions[elementIndex]
            self?.actionsDelegate?.tapResolution(scale: scale)
            self?.isContextVisible.send(false)
        }
    }
    
    private func internalSubscribers() {
        videoPlayer.currentTime.subscribe { [unowned self] seconds in
            timelineLabel.text = seconds > 10 ? "-" + seconds.stringSecondsFormat() : Constants.liveBroadcastText
        }
        
        isPlayingVideo.subscribe { [unowned self] isPlaying in
            isPlaying ? videoPlayer.playVideo() : videoPlayer.pauseVideo()
//            playButton.setState(isPlaying)
        }
        
        isVideoVisible.subscribe { [unowned self] isVisible in
            videoPlayer.isHidden = !isVisible
            playButton.isHidden = !isVisible
        }
        
        isIndicatorVisible.subscribe { [unowned self] isVisible in
            activityIndicator.isHidden = !isVisible
        }
        
        isErrorVisible.subscribe { [unowned self] isError in
            errorLabel.isHidden = !isError
        }
        
        isControlPanelVisible.subscribe { [unowned self] visible in
            visible ? showControlsPanel() : hideControlsPanel()
        }
        
        isContextVisible.subscribe { [unowned self] visible in
            visible ? contextMenu.show() : contextMenu.hide()
        }
    }
    
    private func loadVideo() {
        isIndicatorVisible.send(true)
        isVideoVisible.send(false)
        isErrorVisible.send(false)
        isPlayingVideo.send(false)
    }
    
    private func showError() {
        isVideoVisible.send(false)
        isIndicatorVisible.send(false)
        isContextVisible.send(false)
        isErrorVisible.send(true)
        isPlayingVideo.send(false)
    }
    
    private func playVideo() {
        isVideoVisible.send(true)
        isErrorVisible.send(false)
        isIndicatorVisible.send(false)
        isContextVisible.send(false)
        timerHidingPanel = Timer.scheduledTimer(withTimeInterval: Constants.timerHidingPanelValue, repeats: false) { timer in
            self.isControlPanelVisible.send(false)
        }
        isPlayingVideo.send(true)
    }
    
    private func pauseVideo() {
        timerHidingPanel?.invalidate()
        isVideoVisible.send(true)
        isIndicatorVisible.send(false)
        isControlPanelVisible.send(true)
        isPlayingVideo.send(false)
    }
    
    private func stopPlayer() {
        isPlayingVideo.send(false)
    }
    
    private func showControlsPanel() {
        self.topContainerConstraint.constant = 0
        self.bottomContainerConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.topContainer.layer.opacity = 1
            self.bottomContainer.layer.opacity = 1
            self.playButton.layer.opacity = 1
            self.layoutIfNeeded()
        }
    }
    
    private func hideControlsPanel(_ delay: CGFloat = 0) {
        self.topContainerConstraint.constant = -Constants.padding
        self.bottomContainerConstraint.constant = Constants.padding
        
        UIView.animate(withDuration: 0.3) {
            self.topContainer.layer.opacity = 0
            self.bottomContainer.layer.opacity = 0
            self.playButton.layer.opacity = 0
            self.layoutIfNeeded()
        }
    }
    
    private func showPlayButton() {
        playButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4, delay: .zero, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8) {
            self.playButton.layer.opacity = 1
            self.playButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    private func hidePlayButton() {
        UIView.animate(withDuration: 0.2) {
            self.playButton.layer.opacity = 0
        }
    }
    
    @objc private func playButtonTapped(_ gesture: UITapGestureRecognizer) {
        isPlayingVideo.value ? actionsDelegate?.pauseButtonTapped() : actionsDelegate?.playButtonTapped()
        playButton.buttonTapped(isPlayingVideo.value)
    }
    
    @objc private func playerTapped(_ gesture: UITapGestureRecognizer) {
        timerHidingPanel?.invalidate()
        isContextVisible.send(false)
        if isPlayingVideo.value && !isControlPanelVisible.value {
            self.isControlPanelVisible.send(true)
            timerHidingPanel = Timer.scheduledTimer(withTimeInterval: Constants.timerHidingPanelValue, repeats: false) { timer in
                self.isControlPanelVisible.send(false)
            }
        } else {
            isControlPanelVisible.send(!isControlPanelVisible.value)
        }
    }
    
    @objc private func backButtonTapped(_ button: UIButton) {
        actionsDelegate?.navigationBackButtonTap()
    }
    
    @objc private func settingsButtonTapped(_ button: UIButton) {
        if contextMenu.layer.opacity == 0 {
            timerHidingPanel?.invalidate()
            isContextVisible.send(true)
        } else {
            timerHidingPanel?.invalidate()
            isContextVisible.send(false)
            if isPlayingVideo.value {
                timerHidingPanel = Timer.scheduledTimer(withTimeInterval: Constants.timerHidingPanelValue, repeats: false) { timer in
                    self.isControlPanelVisible.send(false)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topContainer.gradient(start: 0, end: 1)
        bottomContainer.gradient(start: 1, end: 0)
    }
}

// MARK: - Setup view
extension TVPlayerView {
    private func setupView() {
        addSubview(videoPlayer)
        addSubview(activityIndicator)
        addSubview(topContainer)
        addSubview(bottomContainer)
        addSubview(playButton)
        addSubview(contextMenu)
        addSubview(errorLabel)
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
        
        // Center
        let videoPlayerGesture = UITapGestureRecognizer(target: self, action: #selector(playerTapped(_:)))
        videoPlayer.addGestureRecognizer(videoPlayerGesture)
        
        let playButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped(_:)))
        playButton.addGestureRecognizer(playButtonTapGesture)
        playButton.configure(playState: isPlayingVideo.value)
        
        activityIndicator.startAnimating()
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        
        errorLabel.text = Constants.errorLabelText
        errorLabel.textColor = Theme.Colors.lightGray
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.font = .systemFont(ofSize: 22, weight: .light)
        
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
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        timeline.translatesAutoresizingMaskIntoConstraints = false
        timelineLabel.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        contextMenu.translatesAutoresizingMaskIntoConstraints = false
        
        topContainerConstraint = topContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        bottomContainerConstraint = bottomContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        NSLayoutConstraint.activate([
            // Top container
            topContainerConstraint,
            topContainer.heightAnchor.constraint(equalToConstant: Constants.topContainerHeight),
            topContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            
            // Back button
            backButton.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: Constants.padding),
            backButton.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -Constants.padding),
            backButton.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: Constants.smallPadding),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor),
            
            // Channel image
            channelImage.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: Constants.padding),
            channelImage.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -Constants.padding),
            channelImage.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: Constants.smallPadding),
            channelImage.widthAnchor.constraint(equalTo: channelImage.heightAnchor),
            
            // Labels stack view
            topLabelsStackView.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: Constants.padding),
            topLabelsStackView.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -Constants.padding),
            topLabelsStackView.leadingAnchor.constraint(equalTo: channelImage.trailingAnchor, constant: Constants.largePadding),
            topLabelsStackView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -Constants.smallPadding),
            
            // Video player
            videoPlayer.topAnchor.constraint(equalTo: topAnchor),
            videoPlayer.bottomAnchor.constraint(equalTo: bottomAnchor),
            videoPlayer.leadingAnchor.constraint(equalTo: leadingAnchor),
            videoPlayer.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Activity indicator
            activityIndicator.widthAnchor.constraint(equalToConstant: 44),
            activityIndicator.heightAnchor.constraint(equalTo: activityIndicator.widthAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Error label
            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -Constants.largePadding * 2),
            
            // PlayImage
            playButton.widthAnchor.constraint(equalToConstant: Constants.playButtonSide),
            playButton.heightAnchor.constraint(equalToConstant: Constants.playButtonSide),
            playButton.centerXAnchor.constraint(equalTo: videoPlayer.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: videoPlayer.centerYAnchor),
            // Bottom container
            bottomContainerConstraint,
            bottomContainer.heightAnchor.constraint(equalToConstant: Constants.bottomCcontainerHeight + safeAreaInsets.bottom),
            bottomContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            
            // Timeline label
            timelineLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: Constants.padding),
            timelineLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: Constants.smallPadding),
            timelineLabel.widthAnchor.constraint(equalTo: bottomContainer.widthAnchor),
            
            // Settings button
            settingsButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: Constants.padding),
            settingsButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -Constants.smallPadding),
            settingsButton.widthAnchor.constraint(equalToConstant: 24),
            settingsButton.heightAnchor.constraint(equalTo: settingsButton.widthAnchor),
            
            // Tmeline
            timeline.heightAnchor.constraint(equalToConstant: 10),
            timeline.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 6),
            timeline.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: Constants.smallPadding),
            timeline.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -Constants.smallPadding),
            
            // Context menu
            contextMenu.bottomAnchor.constraint(equalTo: settingsButton.topAnchor, constant: -Constants.padding),
            contextMenu.trailingAnchor.constraint(equalTo: settingsButton.trailingAnchor),
            contextMenu.heightAnchor.constraint(equalToConstant: 200),
            contextMenu.widthAnchor.constraint(equalToConstant: 128),
        ])
    }
}
