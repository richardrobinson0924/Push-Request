//
//  iOS_Widget.swift
//  iOS Widget
//
//  Created by Richard Robinson on 2020-11-21.
//

import WidgetKit
import SwiftUI
import Combine



struct Provider: TimelineProvider {
    var cancellables: Set<AnyCancellable> = []
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), eventInfos: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        try! EventController.shared.fetchAllEventsWithData {
            let entry = SimpleEntry(date: Date(), eventInfos: $0)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        self.getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let eventInfos: [(event: WebhookEvent, avatarData: Data)]
}

struct EntryView: View {
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    let eventInfos: [(event: WebhookEvent, avatarData: Data)]

    var body: some View {
        if eventInfos.isEmpty {
            Text("No Activity")
        } else {
            switch self.widgetFamily {
            case .systemMedium:
                MediumWidgetView(
                    event: eventInfos.last!.event,
                    avatarData: eventInfos.last!.avatarData
                )
                .widgetURL(eventInfos.last!.event.url)
                
            default:
                fatalError()
            }
        }
    }
}

struct MediumWidgetView : View {
    let event: WebhookEvent
    let avatarData: Data
    
    var avatar: some View {
        let uiImage = UIImage(data: avatarData)!
        return Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .frame(width: 20, height: 20)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Image(event.eventType.iconName)
                    .resizable()
                    .frame(width: 22, height: 22)
                    .padding(.horizontal, 14)
                    .foregroundColor(event.eventType.iconColor)
                
                Text("\(event.repoName) #\(String(event.number))")
                    .font(.footnote)
            }
            .foregroundColor(.secondary)
            
            Text(event.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 50)
                .lineLimit(3)
            
            Spacer()
            
            HStack {
                avatar
                
                Text(event.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.vertical, 20)
        .background(Color(white: 0.1))
        .colorScheme(.dark)
    }
}

@main
struct iOS_Widget: Widget {
    let kind: String = "iOS_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EntryView(eventInfos: entry.eventInfos)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Push Request")
        .description("See your latest GitHub notifications.")
    }
}

struct iOS_Widget_Previews: PreviewProvider {
    static let data = UIImage(named: "pic")!.pngData()!
    
    static let event = WebhookEvent(
        eventType: .issueAssigned,
        repoName: "instantish / instantish",
        number: 1580,
        title: "Updated next.JS to v10 & Removed `server.js` & Removed unused dependencies",
        description: "@richardrobinson0924 created this pull request",
        avatarUrl: URL(string: "https://avatars3.githubusercontent.com/u/16073505?s=400&u=ca79b02893d6e10fab35e3ba1e593115da64e7ac&v=4")!,
        timestamp: Date().addingTimeInterval(-300),
        url: URL(string: "https://www.apple.com")!
    )
    
    static let events: [(event: WebhookEvent, avatarData: Data)] = [
        (event: event, avatarData: data),
        (event: event, avatarData: data),
        (event: event, avatarData: data)
    ]
    
    static var previews: some View {
        Group {
            EntryView(eventInfos: events)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
