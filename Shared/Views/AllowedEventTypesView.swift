//
//  AllowedEventTypesView.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-26.
//

import SwiftUI

struct AllowedEventTypesView: View {
    @EnvironmentObject var webhookService: WebhookService
    @State private var allowedTypes: [WebhookEvent.EventType] = []
    
    let id: Int
    
    func typeBindingFor(_ type: WebhookEvent.EventType) -> Binding<Bool> {
        Binding { () -> Bool in
            allowedTypes.contains(type)
        } set: { (isAllowed) in
            if isAllowed {
                allowedTypes.append(type)
            } else {
                allowedTypes.removeAll(where: { $0 == type })
            }
        }

    }

    func getCell(for type: WebhookEvent.EventType) -> some View {
        Toggle(isOn: typeBindingFor(type)) {
            Label(type.displayName, image: type.iconName)
                .accentColor(type.iconColor)
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Issues")) {
                ForEach(WebhookEvent.EventType.issues, id: \.self, content: getCell(for:))
            }
            
            Section(header: Text("Pull Requests")) {
                ForEach(WebhookEvent.EventType.prs, id: \.self, content: getCell(for:))
            }
            
            Section(header: Text("PR Reviews")) {
                ForEach(WebhookEvent.EventType.prReviews, id: \.self, content: getCell(for:))
            }
        }
        .navigationTitle("Subscribed Events")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            self.webhookService.getAllowedEventTypes(forUserWithId: id) { (result) in
                switch result {
                case .success(let allowedTypes):
                    self.allowedTypes = allowedTypes
                    
                case .failure(_):
                    fatalError()
                }
            }
        }
        .onChange(of: allowedTypes) { newValue in
            print("setting new allowed event types")
            self.webhookService.setAllowedEventTypes(newValue, forUserWithId: id)
        }
    }
}

struct AllowedEventTypesView_Previews: PreviewProvider {
    static var previews: some View {
        AllowedEventTypesView(id: 0)
            .environmentObject(DummyWebhookService() as WebhookService)
    }
}
