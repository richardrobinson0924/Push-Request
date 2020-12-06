//
//  Environment.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-17.
//

import Foundation

struct Configuration {
    static let shared = Configuration()
    
    let GITHUB_APP_ID: Int
    let GITHUB_CLIENT_ID: String
    let GITHUB_CLIENT_SECRET: String
    let GITHUB_PUBLIC_LINK: URL
    let GITHUB_CALLBACK_URL: URL
    let SERVER_URL: URL
    
    init() {
        let env = ProcessInfo.processInfo.environment
        
        self.GITHUB_APP_ID = Int(env["GITHUB_APP_ID"]!)!
        self.GITHUB_CLIENT_ID = env["GITHUB_CLIENT_ID"]!
        self.GITHUB_CLIENT_SECRET = env["GITHUB_CLIENT_SECRET"]!
        self.GITHUB_PUBLIC_LINK = URL(string: env["GITHUB_PUBLIC_LINK"]!)!
        self.GITHUB_CALLBACK_URL = URL(string: env["GITHUB_CALLBACK_URL"]!)!
        self.SERVER_URL = URL(string: env["SERVER_URL"]!)!
    }
}
