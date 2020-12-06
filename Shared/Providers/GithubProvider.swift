//
//  GithubProvider.swift
//  Push Request (iOS)
//
//  Created by Richard Robinson on 2020-12-05.
//

import Foundation
import Combine

class GithubProvider<S: Scheduler>: ObservableObject {
    private let githubService: GithubService
    private let scheduler: S
    
    @Published var numberOfInstallations: Int = 0
    
    init(using service: GithubService, on scheduler: S) {
        self.githubService = service
        self.scheduler = scheduler
    }
    
    func loadNumberOfInstallations(from token: String) {
        self.githubService.getNumberOfInstallations(from: token)
            .receive(on: scheduler)
            .replaceNil(with: 0)
            .replaceError(with: 0)
            .assign(to: &$numberOfInstallations)
    }
}
