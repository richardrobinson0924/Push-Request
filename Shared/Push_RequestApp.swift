//
//  Push_RequestApp.swift
//  Shared
//
//  Created by Richard Robinson on 2020-11-17.
//

import SwiftUI

@main
struct Push_RequestApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    let githubService = GithubService()
    let webhookService = WebhookService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        self.githubService.getUser(from: accessToken) { (result) in
            switch result {
            case .success(let user):
                let webhookUser = WebhookUser(
                    accessToken: accessToken,
                    githubId: user.id,
                    deviceToken: deviceTokenString
                )
                
                self.webhookService.addUser(webhookUser)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
}
#endif
