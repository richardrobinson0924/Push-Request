//
//  WebhookUser.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-18.
//

import Foundation
import SwiftUI

struct WebhookEvent: Codable, Hashable {
    enum EventType: String, Codable, CaseIterable {
        case issueOpened, issueClosed, issueAssigned
        case prOpened, prClosed, prMerged
        case prReviewRequested, prReviewed
    }
    
    let eventType: EventType
    let repoName: String
    let number: Int
    let title: String
    let description: String
    let avatarUrl: URL
    let timestamp: Date
    let url: URL
}

struct WebhookUser: Codable {
    let githubId: Int
    let deviceTokens: [String]
    let latestEvent: WebhookEvent?
    let allowedTypes: [WebhookEvent.EventType]
}

extension WebhookEvent.EventType {
    static let issues: [WebhookEvent.EventType] = [.issueOpened, .issueClosed, .issueAssigned]
    static let prs: [WebhookEvent.EventType] = [.prMerged, .prOpened, .prClosed]
    static let prReviews: [WebhookEvent.EventType] = [.prReviewed, .prReviewRequested]
}

extension WebhookEvent.EventType {
    var displayName: String {
        switch self {
        case .issueOpened:
            return "Opened Issues"
        
        case .issueClosed:
            return "Closed Issues"
            
        case .issueAssigned:
            return "Assigned Issues"
            
        case .prOpened:
            return "Opened Pull Requests"
            
        case .prClosed:
            return "Closed Pull Requests"
            
        case .prMerged:
            return "Merged Pull Requests"
            
        case .prReviewRequested:
            return "PR Review Requests"
            
        case .prReviewed:
            return "PR Reviews"
        }
    }
    
    var iconName: String {
        switch self {
        case .issueAssigned, .issueOpened:
            return "Open Issue"
            
        case .prOpened, .prClosed:
            return "Pull Request"
            
        case .prReviewed, .prReviewRequested:
            return "Code Review"
            
        case .issueClosed:
            return "Closed Issue"
            
        case .prMerged:
            return "Merged Pull Request"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .issueClosed, .prClosed:
            return .ghRed
            
        case .prMerged:
            return .ghPurple
            
        case .issueAssigned, .prOpened, .issueOpened:
            return .ghGreen
            
        case .prReviewRequested, .prReviewed:
            return .ghGray
        }
    }
}

