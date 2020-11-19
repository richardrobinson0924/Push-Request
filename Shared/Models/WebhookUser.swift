//
//  WebhookUser.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-18.
//

import Foundation

struct WebhookUser: Codable {
    let accessToken: String
    let githubId: Int
    let deviceToken: String
}
