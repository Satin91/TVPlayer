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

struct TVChannel: Decodable {
    var id: Int
    var name: String?
    var currentBroadcast: Broadcast
    var imageURL: URL
}

struct Broadcast: Decodable {
    var title: String
}

extension TVChannel {
    enum CodingKeys: String, CodingKey {
        case id
        case name_ru
        case current
        case image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name_ru)
        self.currentBroadcast = try container.decode(Broadcast.self, forKey: .current)
        self.imageURL = try container.decode(URL.self, forKey: .image)
    }
}

