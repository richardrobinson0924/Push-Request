//
//  Environment.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-17.
//

import Foundation

struct Configuration: Codable {
    static let shared = Configuration()
    
    let githubAppId: Int
    let githubClientId: String
    let githubClientSecret: String
    let githubRedirectUri: String
    let githubAppLink: String
    
    init() {
        let path = Bundle.main.path(forResource: "Preferences", ofType: "plist")!
        let xml = FileManager.default.contents(atPath: path)!
        self = try! PropertyListDecoder().decode(Self.self, from: xml)
    }
}
