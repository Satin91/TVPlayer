//
//  TVChannelsController.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

class TVChannelsController: UIViewController {
    let service = TVChannelService()
    
    private var tvView = TVChannelsView()
    
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadChannels()
    }
     
    func setupView() {
        self.view = tvView
    }
    
    func loadChannels() {
        service.getChannels { channels in
            self.tvView.configure(with: channels)
        }
    }
}
