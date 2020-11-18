//
//  WebhookService.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-18.
//

import Foundation

class WebhookService: ObservableObject {
    private let urlSession = URLSession.shared

    func addUser(_ user: WebhookUser) {
        let url = URL(scheme: "https", host: "push-request-server.herokuapp.com", path: "/users")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try! JSONEncoder().encode(user)
        
        self.urlSession.dataTask(with: urlRequest).resume()
    }
}
