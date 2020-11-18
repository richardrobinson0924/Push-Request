//
//  WebhookUser.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-18.
//

import Foundation

struct WebhookUser: Encodable {
    let accessToken: String
    let githubId: Int
    let deviceToken: String
    
    init(accessToken: String, githubId: Int, deviceToken: String) {
        self.accessToken = accessToken
        self.githubId = githubId
        self.deviceToken = deviceToken
    }
}
