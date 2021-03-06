//
//  URL+Extensions.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-18.
//

import Foundation

extension URL {
    init?(scheme: String, host: String, path: String?, queryItems: [URLQueryItem]? = nil) {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.queryItems = queryItems
        
        if let path = path {
            components.path = path
        }
        
        if let url = components.url {
            self = url
        } else {
            return nil
        }
    }
}

extension URLRequest {
    enum HTTPMethod: String {
        case get = "GET"
        case patch = "PATCH"
        case post = "POST"
    }
    
    init(url: URL, httpMethod: HTTPMethod = .get, httpBody: Data? = nil, httpHeaders: [String : String] = [:]) {
        self.init(url: url)
        self.httpMethod = httpMethod.rawValue
        self.httpBody = httpBody
    
        for header in httpHeaders {
            self.setValue(header.value, forHTTPHeaderField: header.key)
        }
    }
}
