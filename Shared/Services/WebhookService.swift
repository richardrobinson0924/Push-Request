//
//  WebhookService.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-18.
//

import Foundation
import Combine

struct AllowedTypes: Codable {
    let allowedTypes: [WebhookEvent.EventType]
}

class DummyWebhookService: WebhookService {
    private static let event = WebhookEvent(
        eventType: .issueAssigned,
        repoName: "instantish / instantish",
        number: 1580,
        title: "Updated next.JS to v10 & Removed `server.js` & Removed unused dependencies",
        description: "@richardrobinson0924 created this pull request",
        avatarUrl: URL(string: "https://avatars3.githubusercontent.com/u/16073505?s=400&u=ca79b02893d6e10fab35e3ba1e593115da64e7ac&v=4")!,
        timestamp: Date().addingTimeInterval(-300),
        url: URL(string: "https://www.apple.com")!
    )
    
    private static let user = WebhookUser(
        githubId: 1,
        deviceTokens: [],
        latestEvent: event,
        allowedTypes: [.issueAssigned, .issueOpened, .prMerged]
    )
    
    override func addUser(_ user: WebhookUser) {
    }
    
    override func getUser(forUserWithId id: Int) -> AnyPublisher<WebhookUser, Error> {
        return Just(Self.user)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    override func updateUser(withAllowedEventTypes allowedEventTypes: [WebhookEvent.EventType], forUserWithId id: Int) {
    }
}

class WebhookService: ObservableObject {
    private let urlSession = URLSession.shared
    
    private var jsonDecoder: JSONDecoder {
        let res = JSONDecoder()
        res.keyDecodingStrategy = .convertFromSnakeCase
        res.dateDecodingStrategy = .iso8601
        return res
    }
    
    private var jsonEncoder: JSONEncoder {
        let res = JSONEncoder()
        res.dateEncodingStrategy = .iso8601
        res.keyEncodingStrategy = .convertToSnakeCase
        return res
    }

    func addUser(_ user: WebhookUser) {
        let url = Configuration.shared.SERVER_URL.appendingPathComponent("/users")
        
        let request = URLRequest(
            url: url,
            httpMethod: .post,
            httpBody: try! self.jsonEncoder.encode(user),
            httpHeaders: [
                "Content-Type": "application/json",
            ]
        )
        
        self.urlSession.dataTask(with: request).resume()
    }
    
    func getUser(forUserWithId id: Int) -> AnyPublisher<WebhookUser, Error> {
        let url = Configuration.shared.SERVER_URL.appendingPathComponent("/users")
        
        let request = URLRequest(url: url, httpHeaders: ["Authorization": String(id)])
        
        return self.urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: WebhookUser.self, decoder: self.jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    func updateUser(withAllowedEventTypes allowedEventTypes: [WebhookEvent.EventType], forUserWithId id: Int) {
        let url = Configuration.shared.SERVER_URL.appendingPathComponent("/users")
        let data = AllowedTypes(allowedTypes: allowedEventTypes)
        
        let request = URLRequest(
            url: url,
            httpMethod: .patch,
            httpBody: try! self.jsonEncoder.encode(data),
            httpHeaders: [
                "Content-Type": "application/json",
                "Authorization": String(id)
            ]
        )
        
        self.urlSession.dataTask(with: request).resume()
    }
}
