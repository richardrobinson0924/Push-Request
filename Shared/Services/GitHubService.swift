//
//  GithubService.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-18.
//

import Foundation
import Combine

struct Installations: Codable {
    let totalCount: Int?
}

class GithubService: ObservableObject {
    private let urlSession = URLSession.shared
    
    private var jsonDecoder: JSONDecoder {
        let res = JSONDecoder()
        res.keyDecodingStrategy = .convertFromSnakeCase
        res.dateDecodingStrategy = .iso8601
        return res
    }
    
    func getUser(from accessToken: String) -> AnyPublisher<GithubUser, Error> {
        print("getting user from access token \(accessToken)")
        let url = URL(scheme: "https", host: "api.github.com", path: "/user")!
        
        let request = URLRequest(
            url: url,
            httpHeaders: [
                "Accept": "application/vnd.github.v3+json",
                "Authorization": "token \(accessToken)"
            ]
        )
        
        return self.urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .print()
            .decode(type: GithubUser.self, decoder: self.jsonDecoder)
            .breakpointOnError()
            .eraseToAnyPublisher()
    }
    
    func getNumberOfInstallations(from accessToken: String) -> AnyPublisher<Int?, Never> {
        let url = URL(scheme: "https", host: "api.github.com", path: "/user/installations")!
        
        let request = URLRequest(
            url: url,
            httpHeaders: [
                "Accept": "application/vnd.github.v3+json",
                "Authorization": "token \(accessToken)"
            ]
        )
        
        return self.urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Installations.self, decoder: self.jsonDecoder)
            .breakpointOnError()
            .map(\.totalCount)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
