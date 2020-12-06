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
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let webhookService = WebhookService()
    let githubService = GithubService()
    
    var cancellables = Set<AnyCancellable>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let accessToken = UserDefaults.group.string(forKey: "accessToken")!
        
        let receiveValue = { (ghUser: GithubUser) in
            UserDefaults.group.set(ghUser.id, forKey: "githubId")
            
            let webhookUser = WebhookUser(
                githubId: ghUser.id,
                deviceTokens: [deviceTokenString],
                latestEvent: nil,
                allowedTypes: WebhookEvent.EventType.allCases
            )
            
            self.webhookService.addUser(webhookUser)
        }
        
        let receiveCompletion = { (error: Subscribers.Completion<Error>) in
            print(error)
        }
        
        self.githubService.getUser(from: accessToken)
            .sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
            .store(in: &cancellables)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("received new data")
        
        let id = UserDefaults.group.integer(forKey: "githubId")
        guard id != 0 else {
            completionHandler(.failed)
            return
        }
        
        let receiveValue = { (event: WebhookEvent?) in
            try! EventController.shared.append(event: event!)
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        let receiveCompletion = { (completion: Subscribers.Completion<Error>) in
            switch completion {
            case .failure(let error):
                print(error)
                completionHandler(.failed)
                
            case .finished:
                completionHandler(.newData)
            }
        }
        
        self.webhookService.getUser(forUserWithId: id)
            .map(\.latestEvent)
            .sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
            .store(in: &cancellables)
    }
}
