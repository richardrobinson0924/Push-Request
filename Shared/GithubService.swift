//
//  GithubService.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-18.
//

import Foundation

class GithubService: ObservableObject {
    private let urlSession = URLSession.shared
    
    func getUser(from accessToken: String, completion: @escaping (Result<GithubUser, Error>) -> Void) {
        let url = URL(scheme: "https", host: "api.github.com", path: "/user")!
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        self.urlSession.dataTask(with: request) { (data, response, error) in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let result = Result {
                try decoder.decode(GithubUser.self, from: data!)
            }
            
            completion(result)
        }.resume()
    }
}
