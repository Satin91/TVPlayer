//
//  TVChannelsStorageService.swift
//  TVPlayer
//
//  Created by Артур Кулик on 27.12.2023.
//

import Foundation
import CoreData

protocol TVChannelsStorageServiceProtocol {
    func create(channel: TVChannel)
    func fetchAll() -> [TVChannel]
    func remove(with id: Int)
}

final class TVChannelsStorageService: TVChannelsStorageServiceProtocol {
    let manager: StorageManagerProtocol
    var context: NSManagedObjectContext
    
    init(manager: StorageManagerProtocol, context: NSManagedObjectContext) {
        self.manager = manager
        self.context = context
    }
    
    func create(channel: TVChannel) {
        let predicate = NSPredicate(format: "id = %i", channel.id)
        guard manager.isExists(object: TVChannelCore.self, with: predicate) == false else { return }
        guard let description = NSEntityDescription.entity(forEntityName: "TVChannelCore", in: context) else { return }
        let channelCore = TVChannelCore(entity: description, insertInto: context)
        channelCore.id = Int64(channel.id)
        channelCore.name = channel.name
        channelCore.imageURL = channel.imageURL
        channelCore.channelURL = channel.channelURL
        channelCore.currentBroadcast = channel.currentBroadcast.title
        channelCore.isFavorite = true
        manager.create(object: channelCore)
    }
    
    func fetchAll() -> [TVChannel] {
        let channelsCore: [TVChannelCore] = manager.fetchAll()
        guard !channelsCore.isEmpty else { return [] }
        let channels = channelsCore.map { TVChannel(channelCore: $0) }
        return channels
    }
    
    func remove(with id: Int) {
        let predicate = NSPredicate(format: "id = %i", id)
        manager.delete(object: TVChannelCore.self, with: predicate)
    }
}
