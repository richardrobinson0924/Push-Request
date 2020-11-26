//
//  Push_RequestApp.swift
//  Shared
//
//  Created by Richard Robinson on 2020-11-17.
//

import SwiftUI
import Combine
import WidgetKit

@main
struct Push_RequestApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #else
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class UniversalAppDelegate: NSObject {
    let webhookService = WebhookService()
    let githubService = GithubService()

    func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let accessToken = UserDefaults.group!.string(forKey: "accessToken")!
                
        githubService.getUser(from: accessToken) { (result) in
            switch result {
            case .success(let ghUser):
                UserDefaults.group!.set(ghUser.id, forKey: "githubId")
                
                let webhookUser = WebhookUser(
                    githubId: ghUser.id,
                    deviceToken: deviceTokenString,
                    events: [],
                    allowedTypes: WebhookEvent.EventType.allCases
                )
                self.webhookService.addUser(webhookUser)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func application(didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print("received new data")
        
        let id = UserDefaults.group!.integer(forKey: "githubId")
        guard id != 0 else {
            completionHandler(false)
            return
        }
        
        self.webhookService.getLatestEvent(forUserWithId: id) { (result) in
            switch result {
            case .success(let event):
                try! UserDefaults.group!.append(event, toArrayWithKey: "events")
                WidgetCenter.shared.reloadAllTimelines()
                completionHandler(true)
                
            case .failure(_):
                completionHandler(false)
            }
        }
    }
}

#if os(iOS)
class AppDelegate: UniversalAppDelegate, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        super.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        super.application(didReceiveRemoteNotification: userInfo) { (didSucceed) in
            completionHandler(didSucceed ? .newData : .failed)
        }
    }
}
#else
class AppDelegate: UniversalAppDelegate, NSApplicationDelegate {
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        super.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        super.application(didReceiveRemoteNotification: userInfo) { _ in }
    }
}
#endif
