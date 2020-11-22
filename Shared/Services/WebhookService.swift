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

class WebhookService: ObservableObject {
    private let urlSession = URLSession.shared

    func addUser(_ user: WebhookUser) {
        let url = URL(scheme: "https", host: "push-request-server.herokuapp.com", path: "/users")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try! JSONEncoder().encode(user)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.urlSession.dataTask(with: urlRequest).resume()
    }
    
    func getLatestEvent(forUserWithAccessToken accesssToken: String, _ completion: @escaping (Result<WebhookEvent, Error>) -> Void) {
        let url = URL(scheme: "https", host: "push-request-server.herokuapp.com", path: "/users/latest-event")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(accesssToken, forHTTPHeaderField: "Authorization")
        
        
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
