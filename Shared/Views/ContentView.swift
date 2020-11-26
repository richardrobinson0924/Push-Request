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
        SignInWithGitHubView {
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
        AuthorizeAppView {
            openURL(url)
        }
    }
}

struct MainView: View {
    var body: some View {
        NavigationView {
            Text("🚧 Under Construction 🚧")
                .navigationTitle("Push Request")
        }
    }
}

struct ContentView: View {
    @Environment(\.openURL) var openURL

    @StateObject var authenticationService = AuthenticationService()
    @StateObject var githubService = GithubService()
    @StateObject var webhookService = WebhookService()
    
    @AppStorage("accessToken", store: .group) var accessToken: String = ""
    @AppStorage("ghAppInstalled", store: .group) var hasGithubAppBeenInstalled: Bool = false
    @AppStorage("githubId", store: .group) var id: Int = 0
    
    func onOpenURLFromAuthentication(_ url: URL) {
        self.authenticationService.onRedirect(from: url) { (result) in
            switch result {
            case .success(let token):
                self.githubService.getNumberOfInstallations(from: token.accessToken) { (n) in
                    if let n = n, n > 0 {
                        self.hasGithubAppBeenInstalled = true
                    }
                    
                    self.accessToken = token.accessToken
                    #if os(iOS)
                    DispatchQueue.main.async(execute: UIApplication.shared.registerForRemoteNotifications)
                    #else
                    NSApplication.shared.registerForRemoteNotifications()
                    #endif
                }
                
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
            if id == 0 {
                EmptyView()
            } else {
                TabView {
                    MainView()
                        .tabItem {
                            Image(systemName: "note")
                            Text("Home")
                        }
                    
                    Settings(id: id)
                        .environmentObject(webhookService as WebhookService)
                        .tabItem {
                            Image(systemName: "gearshape")
                            Text("Settings")
                        }
                }
                .onOpenURL(perform: openURL.callAsFunction(_:))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(webhookService: DummyWebhookService(), accessToken: "", hasGithubAppBeenInstalled: true, id: 1)
    }
}
