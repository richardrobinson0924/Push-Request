//
//  Settings.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-26.
//

import SwiftUI

struct Settings: View {
    let id: Int
    
    var url: URL {
        let path = "/installations/new"
        let schemeHost = Configuration.shared.githubAppLink
        
        return URL(string: "\(schemeHost)\(path)")!
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink("Subscribed Events", destination: AllowedEventTypesView(id: id))
                }
                
                Section {
                    Link("Add another GitHub Organization", destination: url)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(id: 1)
            .environmentObject(DummyWebhookService() as WebhookService)
    }
}
