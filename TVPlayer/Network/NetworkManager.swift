//
//  NetworkManager.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import Foundation

protocol NetworkManagerProtocol {
    func parse<T: Decodable>(responseOf: T.Type, completion: (T) -> Void )
}

final class NetworkManager: NetworkManagerProtocol {
    let decoder = JSONDecoder()
    
    func parse<T: Decodable>(responseOf: T.Type, completion: (T) -> Void ) {
        guard let data = readLocalJSONFile(forName: "response") else {
            return
        }
        do {
            let decodedData = try decoder.decode(responseOf.self, from: data)
            completion(decodedData)
        } catch {
            fatalError("Error \(error)")
        }
    }
    
    private func readLocalJSONFile(forName name: String) -> Data? {
        do {
            if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
                let fileUrl = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: fileUrl)
                return data
            }
        } catch {
            print("error: \(error)")
        }
        return nil
    }
}
