//
//  ContentView.swift
//  Shared
//
//  Created by Richard Robinson on 2020-11-17.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var authenticationService: AuthenticationService
    
    var body: some View {
        Button("Login with GitHub") {
            openURL(self.authenticationService.getAuthorizationURL()!)
        }
    }
}

struct InstallGHAppView: View {
    @Environment(\.openURL) var openURL
    
    var url: URL {
        let path = "/installations/new"
        let schemeHost = Configuration.shared.githubAppLink
        
        return URL(string: "\(schemeHost)\(path)")!
    }

    var body: some View {
        Button("Install Github App") {
            openURL(url)
        }
    }
}

struct ContentView: View {
    @StateObject var authenticationService = AuthenticationService()
    @AppStorage("accessToken") var accessToken: String = ""
    @AppStorage("ghAppInstalled") var hasGithubAppBeenInstalled: Bool = false
    
    func onOpenURLFromAuthentication(_ url: URL) {
        self.authenticationService.onRedirect(from: url) { (result) in
            switch result {
            case .success(let token):
                self.accessToken = token.accessToken
                #if os(iOS)
                DispatchQueue.main.async(execute: UIApplication.shared.registerForRemoteNotifications)
                #else
                NSApplication.shared.registerForRemoteNotifications()
                #endif
                
            case .failure(let error):
                print(error)
            }
        }
    }

    
    var body: some View {
        switch (self.accessToken, self.hasGithubAppBeenInstalled) {
        case ("", false):
            LoginView()
                .environmentObject(self.authenticationService)
                .onOpenURL(perform: self.onOpenURLFromAuthentication)
        
        case (_, false):
            InstallGHAppView()
                .onOpenURL { _ in
                    self.hasGithubAppBeenInstalled = true
                }
            
        case (_, true):
            Text(self.accessToken)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
