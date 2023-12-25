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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with url: URL?) {
        guard let url = url else  {
            fatalError("URL Not exists")
        }
        player = AVPlayer(url: url)
        player = AVPlayer(url: url)
        playerLayer = .init(player: player)
        layer.addSublayer(playerLayer)
        player.play()
    }
    
    func playVideo() {
        player.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
    }
}
