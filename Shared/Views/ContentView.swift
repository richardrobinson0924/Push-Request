//
//  ContentView.swift
//  Shared
//
//  Created by Richard Robinson on 2020-11-17.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var authenticationProvider: AuthenticationProvider<DispatchQueue>
    
    var body: some View {
        SignInWithGitHubView {
            openURL(self.authenticationProvider.getAuthorizationURL()!)
        }
    }
}

struct InstallGHAppView: View {
    @Environment(\.openURL) var openURL
    
    var url: URL {
        Configuration.shared.GITHUB_PUBLIC_LINK.appendingPathComponent("/installations/new")
    }

    var body: some View {
        AuthorizeAppView {
            openURL(url)
        }
    }
}

struct MainView: View {
    @EnvironmentObject var webhookProvider: WebhookProvider<DispatchQueue>
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    let id: Int
    
    @State private var info: (event: WebhookEvent, avatarData: Data)? = nil
    @State private var viewState = CGSize.zero
    @State private var isDragging = false
    
    func makeLabel(title: String, systemName: String, iconColor: Color, textColor: Color) -> some View {
        CellLabel(
            title: title,
            textColor: textColor,
            image: Image(systemName: systemName),
            iconColor: iconColor
        )
    }
    
    var url: URL {
        Configuration.shared.GITHUB_PUBLIC_LINK.appendingPathComponent("/installations/new")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: AllowedEventTypesView(id: id)) {
                        makeLabel(
                            title: "Subscribed Events",
                            systemName: "bell.fill",
                            iconColor: .green,
                            textColor: .primary
                        )
                    }

                    Link(destination: url) {
                        makeLabel(
                            title: "Add Another GitHub Organization",
                            systemName: "arrow.up.forward",
                            iconColor: .blue,
                            textColor: .blue
                        )
                    }
                }
                
                Section {
                    Link(destination: URL(string: "mailto:robinson.ian.richard@gmail.com")!) {
                        makeLabel(
                            title: "Contact Support",
                            systemName: "at",
                            iconColor: .pink,
                            textColor: .primary
                        )
                    }
                    
//                    Link(destination: URL(string: "mailto:robinson.ian.richard@gmail.com")!) {
//                        makeLabel(
//                            title: "Review on the App Store",
//                            systemName: "heart.fill",
//                            iconColor: .pink,
//                            textColor: .primary
//                        )
//                    }
                }
            }
            .navigationTitle("Push Request")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            self.webhookProvider.loadLatestEvent(forUserWithId: id)
        }
    }
}

struct ContentView: View {
    @Environment(\.openURL) var openURL

    @StateObject var authenticationProvider = AuthenticationProvider(using: AuthenticationService(), on: DispatchQueue.main)
    @StateObject var githubProvider = GithubProvider(using: GithubService(), on: DispatchQueue.main)
    @StateObject var webhookProvider = WebhookProvider(using: WebhookService(), on: DispatchQueue.main)
    
    @AppStorage("accessToken", store: .group) var accessToken: String = ""
    @AppStorage("ghAppInstalled", store: .group) var hasGithubAppBeenInstalled: Bool = false
    @AppStorage("githubId", store: .group) var id: Int = 0
    
    var body: some View {
        switch (self.accessToken, self.hasGithubAppBeenInstalled) {
        case ("", false):
            LoginView()
                .environmentObject(self.authenticationProvider)
                .onOpenURL(perform: self.authenticationProvider.loadAccessToken)
                .onReceive(authenticationProvider.$accessToken) {
                    guard let token = $0 else {
                        return
                    }
                    
                    self.githubProvider.loadNumberOfInstallations(from: token.accessToken)
                }
                .onReceive(githubProvider.$numberOfInstallations) { n in
                    if n > 0 {
                        self.hasGithubAppBeenInstalled = true
                    }
                    
                    guard let token = authenticationProvider.accessToken?.accessToken else {
                        return
                    }
                    
                    self.accessToken = token
                    DispatchQueue.main.async(execute: UIApplication.shared.registerForRemoteNotifications)
                }
        
        case (_, false):
            InstallGHAppView()
                .onOpenURL { _ in
                    self.hasGithubAppBeenInstalled = true
                }
            
        case (_, true):
            if id == 0 {
                EmptyView()
            } else {
                MainView(id: id)
                .environmentObject(webhookProvider)
                .onOpenURL(perform: openURL.callAsFunction(_:))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            webhookProvider: WebhookProvider(using: DummyWebhookService(), on: .main),
            accessToken: "",
            hasGithubAppBeenInstalled: true,
            id: 1
        )
            .preferredColorScheme(.dark)
    }
}
