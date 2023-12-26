//
//  VideoPlayer.swift
//  TVPlayer
//
//  Created by Артур Кулик on 24.12.2023.
//

import Foundation
import AVKit
import AVFoundation

class VideoPlayer: UIView {
    
    private var player = AVPlayer()
    private var playerLayer = AVPlayerLayer()
    
    var observer: NSKeyValueObservation?
    
    private var maxSeconds: Double = 0
    
    private var readyToPlay: (() -> Void)?
    
    func configure(with url: URL?) {
        guard let url = url else  {
            // TODO: Make error
            fatalError("URL Not exists")
        }
        player = AVPlayer(url: url)
        player = AVPlayer(url: url)
        playerLayer = .init(player: player)
        layer.addSublayer(playerLayer)
        subscribe()
    }
    
    
    func subscribe() {
        let item = player.currentItem
        observer = item?.observe(\.status, changeHandler: { [weak self] item, value in
            if !item.isPlaybackLikelyToKeepUp {
                self?.maxSeconds = self?.player.currentTime().seconds ?? 0
                self?.readyToPlay?()
            }
        })
    }
    
    func videoLoadingComplete(_ handler: @escaping () -> Void) {
        readyToPlay = {
            handler()
        }
    }
    
    func playVideo() {
        player.play()
    }
    
    func pauseVideo() {
        player.pause()
    }
    
    func changeTimeline(forTime: CGFloat, newTime: (Double) -> Void ) {

        let currentTime = player.currentTime()
        let scale = currentTime.timescale
        let rewindTime = self.maxSeconds * Double(forTime) / 100
        let seekTime = CMTime(seconds: rewindTime, preferredTimescale: scale)
        
        player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
        let rewTime = maxSeconds - rewindTime
        newTime(rewTime)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
        
    }
    
    deinit {
        observer?.invalidate()
    }
}
