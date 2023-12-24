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

class TVChannel: NSObject, Decodable {
    @objc dynamic var id: Int
    @objc dynamic var name: String
    @objc dynamic var currentBroadcast: Broadcast
    @objc dynamic var imageURL: URL
    @objc dynamic var isFavorite: Bool
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name_ru)
        self.currentBroadcast = try container.decode(Broadcast.self, forKey: .current)
        self.imageURL = try container.decode(URL.self, forKey: .image)
        self.isFavorite = false
    }
}

class Broadcast: NSObject, Decodable {
    @objc dynamic var title: String
}

extension TVChannel {
    enum CodingKeys: String, CodingKey {
        case id
        case name_ru
        case current
        case image
    }
}

