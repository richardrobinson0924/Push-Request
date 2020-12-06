//
//  AllowedEventTypesView.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-26.
//

import SwiftUI

struct AllowedEventTypesView: View {
    @EnvironmentObject var webhookProvider: WebhookProvider<DispatchQueue>
    
    let id: Int
    
    func typeBindingFor(_ type: WebhookEvent.EventType) -> Binding<Bool> {
        Binding { () -> Bool in
            self.webhookProvider.allowedEventTypes.contains(type)
        } set: { (isAllowed) in
            if isAllowed {
                self.webhookProvider.allowedEventTypes.append(type)
            } else {
                self.webhookProvider.allowedEventTypes.removeAll(where: { $0 == type })
            }
        }

    }

    func getCell(for type: WebhookEvent.EventType) -> some View {
        Toggle(isOn: typeBindingFor(type)) {
            CellLabel(
                title: type.displayName,
                textColor: .primary,
                image: Image(type.iconName).resizable(),
                iconColor: type.iconColor
            )
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
            self.webhookProvider.loadAllowedEventTypes(forUserWithId: id)
        }
        .onDisappear {
            self.webhookProvider.updateAllowedEventTypes(forUserWithId: id)
        }
    }
}

struct AllowedEventTypesView_Previews: PreviewProvider {
    static var previews: some View {
        AllowedEventTypesView(id: 0)
            .environmentObject(WebhookProvider(using: DummyWebhookService() as WebhookService, on: DispatchQueue.main))
    }
}
