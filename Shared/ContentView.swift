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

struct ContentView: View {
    @StateObject var authenticationService = AuthenticationService()
    @AppStorage("accessToken") var accessToken: String = ""
    
    func onOpenURL(_ url: URL) {
        self.authenticationService.onRedirect(from: url) { (result) in
            switch result {
            case .success(let token):
                self.accessToken = token.accessToken
                #if os(iOS)
                UIApplication.shared.registerForRemoteNotifications()
                #else
                NSApplication.shared.registerForRemoteNotifications()
                #endif
                
            case .failure(let error):
                print(error)
            }
        }
    }

    
    var body: some View {
        if self.accessToken == "" {
            LoginView()
                .environmentObject(self.authenticationService)
                .onOpenURL(perform: self.onOpenURL)
        } else {
            Text(self.accessToken)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
