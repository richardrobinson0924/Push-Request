//
//  WebhookService.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-18.
//

import Foundation

enum NetworkError: Error {
    case noData
}

struct AllowedTypes: Codable {
    let allowedTypes: [WebhookEvent.EventType]
}

class DummyWebhookService: WebhookService {
    override func addUser(_ user: WebhookUser) {
    }
    
    override func getAllowedEventTypes(forUserWithId id: Int, _ completion: @escaping (Result<[WebhookEvent.EventType], Error>) -> Void) {
        completion(.success([.issueAssigned, .prMerged, .prReviewed]))
    }
    
    override func setAllowedEventTypes(_ allowedEventTypes: [WebhookEvent.EventType], forUserWithId id: Int) {
    }
    
    override func getLatestEvent(forUserWithId id: Int, _ completion: @escaping (Result<WebhookEvent, Error>) -> Void) {
    }
}

class WebhookService: ObservableObject {
    private let urlSession = URLSession.shared

    func addUser(_ user: WebhookUser) {
        let url = URL(scheme: "https", host: "push-request-server.herokuapp.com", path: "/users/new")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try! JSONEncoder().encode(user)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.urlSession.dataTask(with: urlRequest).resume()
    }
    
    func getAllowedEventTypes(forUserWithId id: Int, _ completion: @escaping (Result<[WebhookEvent.EventType], Error>) -> Void) {
        let url = URL(scheme: "https", host: "push-request-server.herokuapp.com", path: "/users/\(id)/allowed_types")!
        
        self.urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NetworkError.noData))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            let result = Result { () -> [WebhookEvent.EventType] in
                let decoded = try jsonDecoder.decode(AllowedTypes.self, from: data)
                return decoded.allowedTypes
            }
            
            completion(result)
        }.resume()
    }
    
    func setAllowedEventTypes(_ allowedEventTypes: [WebhookEvent.EventType], forUserWithId id: Int) {
        let url = URL(scheme: "https", host: "push-request-server.herokuapp.com", path: "/users/\(id)/allowed_types")!
        let data = AllowedTypes(allowedTypes: allowedEventTypes)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try! JSONEncoder().encode(data)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.urlSession.dataTask(with: urlRequest).resume()
    }
    
    func getLatestEvent(forUserWithId id: Int, _ completion: @escaping (Result<WebhookEvent, Error>) -> Void) {
        let url = URL(scheme: "https", host: "push-request-server.herokuapp.com", path: "/users/latest-event")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(String(id), forHTTPHeaderField: "Authorization")
        
        
        self.urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NetworkError.noData))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            
            let result = Result {
                try jsonDecoder.decode(WebhookEvent.self, from: data)
            }
            
            completion(result)
        }.resume()
    }
}
