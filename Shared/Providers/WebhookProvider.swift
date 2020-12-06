//
//  WebhookProvider.swift
//  Push Request (iOS)
//
//  Created by Richard Robinson on 2020-12-05.
//

import Foundation
import Combine

class WebhookProvider<S: Scheduler>: ObservableObject {
    private let webhookService: WebhookService
    private let subscriber: S
    
    @Published var allowedEventTypes: [WebhookEvent.EventType] = []
    
    @Published var latestEvent: WebhookEvent? = nil
    
    init(using service: WebhookService, on subscriber: S) {
        self.webhookService = service
        self.subscriber = subscriber
    }
    
    func loadAllowedEventTypes(forUserWithId id: Int) {
        self.webhookService.getUser(forUserWithId: id)
            .print()
            .receive(on: subscriber)
            .map(\.allowedTypes)
            .breakpointOnError()
            .replaceError(with: [])
            .assign(to: &$allowedEventTypes)
    }
    
    func loadLatestEvent(forUserWithId id: Int) {
        self.webhookService.getUser(forUserWithId: id)
            .receive(on: subscriber)
            .map(\.latestEvent)
            .replaceError(with: nil)
            .assign(to: &$latestEvent)
    }
    
    func updateAllowedEventTypes(forUserWithId id: Int) {
        print(allowedEventTypes)
        self.webhookService.updateUser(withAllowedEventTypes: allowedEventTypes, forUserWithId: id)
    }
}
