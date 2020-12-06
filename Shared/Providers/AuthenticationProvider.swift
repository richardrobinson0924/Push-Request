//
//  AuthenticationProvider.swift
//  Push Request (iOS)
//
//  Created by Richard Robinson on 2020-12-05.
//

import Foundation
import Combine

class AuthenticationProvider<S: Scheduler>: ObservableObject {
    private let authService: AuthenticationService
    private let scheduler: S
    
    @Published var accessToken: AuthenticationService.AccessToken? = nil
    
    init(using service: AuthenticationService, on scheduler: S) {
        self.authService = service
        self.scheduler = scheduler
    }
    
    func loadAccessToken(from url: URL) {
        self.authService.getAccessToken(onRedirectFrom: url)
            .receive(on: scheduler)
            .breakpointOnError()
            .compactMap { $0 }
            .replaceError(with: nil)
            .assign(to: &$accessToken)
    }
    
    func getAuthorizationURL() -> URL? {
        self.authService.getAuthorizationURL()
    }
}
