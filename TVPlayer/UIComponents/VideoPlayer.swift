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
    
    var currentTime = Observable(Double(0))
    
    
    private var maxPreviousSecondsBuffer: Double = 0
    
    private var loadedCompletedClosure: ((Bool) -> Void)?
    
    public func configure(with url: URL?) {
        guard let url = url else  {
            // TODO: Make error
            fatalError("URL Not exists")
        }
        player = AVPlayer(url: url)
        playerLayer = .init(player: player)
        layer.addSublayer(playerLayer)
        subscribe()
    }
    
    public func playVideo() {
        player.play()
    }
    
    public func pauseVideo() {
        player.pause()
    }
    
    public func videoLoadingComplete(_ handler: @escaping (Bool) -> Void) {
        loadedCompletedClosure = { success in
            handler(success)
        }
    }
    
    public func rewind(to value: CGFloat) {
        let playerTime = player.currentTime()
        let scale = playerTime.timescale
        let rewindTime = self.maxPreviousSecondsBuffer * Double(value) / 100
        let timeForSeek = CMTime(seconds: rewindTime, preferredTimescale: scale)
        player.seek(to: timeForSeek, toleranceBefore: .zero, toleranceAfter: .zero)
        let rewindSeconds = maxPreviousSecondsBuffer - rewindTime
        self.currentTime.send(rewindSeconds)
    }
    
    private func subscribe() {
        let item = player.currentItem
        observer = item?.observe(\.status ) { [weak self] item, value in
            switch item.status {
            case .readyToPlay:
                self?.maxPreviousSecondsBuffer = self?.player.currentTime().seconds ?? 0
                self?.loadedCompletedClosure?(true)
            case .failed:
                self?.loadedCompletedClosure?(false)
            default:
                break
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    deinit {
        observer?.invalidate()
    }
}
