//
//  AuthenticationService.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-17.
//

import Foundation

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
    
    private static let scopes = ["repo:status", "admin:repo_hook", "notifications", "read:user"]
    
    private let state = UUID()
    private let urlSession = URLSession.shared
    
    func getAuthorizationURL() -> URL? {
        let queryItems = [
            URLQueryItem(name: "client_id", value: Configuration.shared.githubClientId),
            URLQueryItem(name: "redirect_uri", value: Configuration.shared.githubRedirectUri),
            URLQueryItem(name: "scope", value: Self.scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: self.state.uuidString)
        ]
        
        return URL(scheme: "https", host: "github.com", path: "/login/oauth/authorize", queryItems: queryItems)
    }
    
    private func getAccessToken(for code: String, _ completion: @escaping (Result<AccessToken, Error>) -> Void) {
        let queryItems = [
            URLQueryItem(name: "client_id", value: Configuration.shared.githubClientId),
            URLQueryItem(name: "client_secret", value: Configuration.shared.githubClientSecret),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "state", value: self.state.uuidString)
        ]
        
        let url = URL(scheme: "https", host: "github.com", path: "/login/oauth/access_token", queryItems: queryItems)!
                
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        self.urlSession.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? AuthenticationError.dataTaskFailure))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let result = Result {
                try jsonDecoder.decode(AccessToken.self, from: data)
            }
            
            completion(result)
        }.resume()
    }
    
    func onRedirect(from url: URL, _ completion: @escaping (Result<AccessToken, Error>) -> Void) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
            let receivedState = components.queryItems?.first(where: { $0.name == "state" })?.value
        else {
            completion(.failure(AuthenticationError.invalidUrl(url)))
            return
        }
        
        guard self.state.uuidString == receivedState else {
            completion(.failure(AuthenticationError.stateMismatch(expected: self.state.uuidString, actual: receivedState)))
            return
        }
        
        self.getAccessToken(for: code, completion)
    }
}
