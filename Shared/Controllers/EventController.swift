//
//  EventController.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-12-05.
//

import Foundation
import Combine

class EventController: ObservableObject {
    static let shared = EventController(userDefaults: .group, maximumNumberOfEvents: 3)
    
    private static let KEY = "push-request-events"
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func fetchAllEventsWithData(_ completion: @escaping ([(event: WebhookEvent, avatarData: Data)]) -> Void) throws {
        let publishers = try allEvents().map(getEventWithData(_:))
        
        Publishers.MergeMany(publishers)
            .replaceError(with: nil)
            .compactMap { $0 }
            .collect()
            .sink(receiveValue: completion)
            .store(in: &cancellables)
    }
    
    private func getEventWithData(_ event: WebhookEvent) -> AnyPublisher<(event: WebhookEvent, avatarData: Data)?, URLError> {
        URLSession.shared.dataTaskPublisher(for: event.avatarUrl)
            .map(\.data)
            .compactMap { (event: event, avatarData: $0) }
            .eraseToAnyPublisher()
    }
}
