//
//  WebhookUser.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-18.
//

import Foundation

struct WebhookEvent: Codable, Hashable {
    enum `Type`: String, Codable {
        case issueOpened, issueClosed, issueAssigned
        case prOpened, prClosed, prMerged
        case prReviewRequested, prReviewed
    }
    
    let eventType: `Type`
    let repoName: String
    let number: Int
    let title: String
    let description: String
    let avatarUrl: URL
    let timestamp: Date
    let url: URL
}

struct WebhookUser: Codable {
    let accessToken: String
    let githubId: Int
    let deviceToken: String
    let events: [WebhookEvent]
}
