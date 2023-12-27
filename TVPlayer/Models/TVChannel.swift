//
//  TVChannel.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import Foundation

struct TVChannelsResponse: Decodable {
    var channels: [TVChannel]
}

class TVChannel: Decodable {
    var id: Int
    var name: String
    var currentBroadcast: Broadcast
    var imageURL: URL
    var channelURL: URL
    var isFavorite: Bool
    
    
    init(channelCore: TVChannelCore) {
        self.id = Int(channelCore.id)
        self.name = channelCore.name ?? "No name"
        self.currentBroadcast = Broadcast(title: channelCore.currentBroadcast ?? "No broadcast")
        self.imageURL = channelCore.imageURL ?? URL(string: "https://spinalcompass.com/wp-content/uploads/2017/07/Employer_icon-01.png")!
        self.channelURL = channelCore.channelURL ?? URL(string: "https://spinalcompass.com/wp-content/uploads/2017/07/Employer_icon-01.png")!
        self.isFavorite = channelCore.isFavorite
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name_ru
        case current
        case image
        case url
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name_ru)
        self.currentBroadcast = try container.decode(Broadcast.self, forKey: .current)
        self.imageURL = try container.decode(URL.self, forKey: .image)
        self.channelURL = try container.decode(URL.self, forKey: .url)
        self.isFavorite = false
    }
}

class Broadcast: Decodable {
    init(title: String) {
        self.title = title
    }
    var title: String
}
