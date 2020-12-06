//
//  AuthenticationService.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-17.
//

import Foundation
import Combine

class AuthenticationService: ObservableObject {
    struct AccessToken: Decodable {
        let accessToken: String
        let scope: String
        let tokenType: String
    }
    
    enum AuthenticationError: Error {
        case invalidUrl(_ url: URL)
        case stateMismatch(expected: String, actual: String)
        case dataTaskFailure
    }
    
    private static let scopes = ["repo:status", "admin:repo_hook", "notifications", "read:user", "repo"]
    
    private let state = UUID()
    private let urlSession = URLSession.shared
    
    func getAuthorizationURL() -> URL? {
        let queryItems = [
            URLQueryItem(name: "client_id", value: Configuration.shared.GITHUB_CLIENT_ID),
            URLQueryItem(name: "redirect_uri", value: Configuration.shared.GITHUB_CALLBACK_URL.absoluteString),
            URLQueryItem(name: "scope", value: Self.scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: self.state.uuidString)
        ]
        
        return URL(scheme: "https", host: "github.com", path: "/login/oauth/authorize", queryItems: queryItems)
    }
    
    private func getAccessToken(for code: String) -> AnyPublisher<AccessToken, Error> {
        let queryItems = [
            URLQueryItem(name: "client_id", value: Configuration.shared.GITHUB_CLIENT_ID),
            URLQueryItem(name: "client_secret", value: Configuration.shared.GITHUB_CLIENT_SECRET),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "state", value: self.state.uuidString)
        ]
        
        let url = URL(scheme: "https", host: "github.com", path: "/login/oauth/access_token", queryItems: queryItems)!
        
        let request = URLRequest(
            url: url,
            httpMethod: .post,
            httpHeaders: ["Accept": "application/json"]
        )
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return self.urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: AccessToken.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func getAccessToken(onRedirectFrom url: URL) -> AnyPublisher<AccessToken, Error> {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
            let receivedState = components.queryItems?.first(where: { $0.name == "state" })?.value
        else {
            return Fail(error: AuthenticationError.invalidUrl(url))
                .eraseToAnyPublisher()
        }
        
        guard self.state.uuidString == receivedState else {
            return Fail(error: AuthenticationError.stateMismatch(expected: self.state.uuidString, actual: receivedState))
                .eraseToAnyPublisher()
        }
        
        return self.getAccessToken(for: code)
    }
}
