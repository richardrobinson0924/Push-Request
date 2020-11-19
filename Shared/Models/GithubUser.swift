//
//  GithubUser.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-18.
//

import Foundation

struct GithubUser: Codable {
    let login: String
    let id: Int
    let avatarUrl: URL
    let url: URL
    let name: String
}
