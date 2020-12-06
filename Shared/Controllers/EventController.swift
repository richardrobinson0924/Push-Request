//
//  EventController.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-12-05.
//

import Foundation

class EventController {
    static let shared = EventController(userDefaults: .group, maximumNumberOfEvents: 3)
    
    private static let KEY = "push-request-events"
    
    private let userDefaults: UserDefaults
    private let maximumNumberOfEvents: Int
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init(userDefaults: UserDefaults, maximumNumberOfEvents: Int) {
        self.userDefaults = userDefaults
        self.maximumNumberOfEvents = maximumNumberOfEvents
    }
    
    func append(event: WebhookEvent) throws {
        let array = try allEvents()
        let newArray = array.suffix(self.maximumNumberOfEvents - 1) + [event]
        
        let encoded = try encoder.encode(Array(newArray))
        self.userDefaults.set(encoded, forKey: Self.KEY)
    }
    
    func allEvents() throws -> [WebhookEvent] {
        let decoded = self.userDefaults.data(forKey: Self.KEY)
        return try decoded.map { try decoder.decode([WebhookEvent].self, from: $0) } ?? []
    }
}
