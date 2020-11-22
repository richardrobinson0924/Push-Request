//
//  UserDefaults+Extensions.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-22.
//

import Foundation

extension UserDefaults {
    static let group = UserDefaults(suiteName: "group.push-request")
    
    func array<Element: Codable>(_ type: Element.Type, forKey key: String) -> [Element]? {
        let decoder = JSONDecoder()
        guard let data = self.data(forKey: key), let result = try? decoder.decode([Element].self, from: data) else {
            return nil
        }
        
        return result
    }
    
    func append<Element: Codable>(_ element: Element, toArrayWithKey key: String) throws {
        let array = self.array(Element.self, forKey: key) ?? []
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(array + [element])
        
        self.set(data, forKey: key)
    }
}
