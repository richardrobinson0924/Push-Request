//
//  iOS_Widget.swift
//  iOS Widget
//
//  Created by Richard Robinson on 2020-11-21.
//

import WidgetKit
import SwiftUI
import Combine

func load(events: [WebhookEvent], completion: @escaping ([CellData]) -> Void) {
    let group = DispatchGroup()
    var result: [CellData] = []
    
    events.forEach { (event) in
        group.enter()
        URLSession.shared.dataTask(with: event.avatarUrl) { (data, response, error) in
            result.append(CellData(event: event, avatarData: data!))
            group.leave()
        }.resume()
    }
    
    group.notify(queue: .main) {
        completion(result)
    }
}

struct Provider: TimelineProvider {
    var cancellables: Set<AnyCancellable> = []
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), events: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), events: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let events = UserDefaults.group!.array(WebhookEvent.self, forKey: "events")!
        assert(!events.isEmpty)
        
        load(events: events) { (result) in
            let entry = SimpleEntry(date: Date(), events: result)
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }
}

struct CellData: Identifiable {
    let id = UUID()
    let event: WebhookEvent
    let avatarData: Data
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let events: [CellData]
}

struct EntryView: View {
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    let events: [CellData]
    
    var body: some View {
        if events.isEmpty {
            Text("No Activity")
        } else {
            switch self.widgetFamily {
            case .systemSmall:
                SmallWidgetView(latestEvent: events.last!)
            case .systemMedium:
                MediumWidgetView(latestEvent: events.last!)
            default:
                LargeWidgetView(events: events)
            }
        }
    }
}

extension WebhookEvent {
    var iconName: String {
        switch eventType {
        case .issueAssigned, .issueOpened:
            return "Open Issue"
            
        case .prReviewed, .prReviewRequested, .prOpened, .prClosed:
            return "Pull Request"
            
        case .issueClosed:
            return "Closed Issue"
            
        case .prMerged:
            return "Merged Pull Request"
        }
    }
    
    var iconColor: Color {
        switch eventType {
        case .issueClosed, .prClosed:
            return .ghRed
            
        case .prMerged:
            return .ghPurple
            
        default:
            return .ghGreen
        }
    }
}

struct SmallWidgetView : View {
    let latestEvent: CellData
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Image(latestEvent.event.iconName)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 6)
                    .foregroundColor(latestEvent.event.iconColor)
                
                Text("\(latestEvent.event.repoName) #\(String(latestEvent.event.number))")
                    .font(.footnote)
                    .lineLimit(2)
            }
            .foregroundColor(.secondary)
            
            
            Text(latestEvent.event.title)
                .font(.footnote)
                .fontWeight(.medium)
                .lineLimit(4)
                .padding(.horizontal, 8)
            
            Spacer()
        }
        .padding(.horizontal, 6)
        .padding(.vertical)
    }
}

struct LargeWidgetView: View {
    let events: [CellData]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(events.suffix(3), id: \.id) { (data) in
                MediumWidgetView(latestEvent: data, padding: 8)
            }
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)    // << here !!
        .background(Color(white: 0.1))
        .colorScheme(.dark)
    }
}

struct MediumWidgetView : View {
    let latestEvent: CellData
    var padding: CGFloat = 20
    
    var avatar: some View {
        let uiImage = NSImage(data: latestEvent.avatarData)!
        return Image(nsImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .frame(width: 20, height: 20)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Image(latestEvent.event.iconName)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 10)
                    .foregroundColor(latestEvent.event.iconColor)
                
                Text("\(latestEvent.event.repoName) #\(String(latestEvent.event.number))")
                    .font(.footnote)
            }
            .foregroundColor(.secondary)
            
            Text(latestEvent.event.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 40)
                .lineLimit(3)
            
            Spacer()
            
            HStack {
                avatar
                
                Text(latestEvent.event.description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)    // << here !!
        .background(Color(white: 0.1))
        .colorScheme(.dark)
    }
}

@main
struct iOS_Widget: Widget {
    let kind: String = "iOS_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EntryView(events: entry.events)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

//struct iOS_Widget_Previews: PreviewProvider {
//    static let data = NSImage(named: "pic")!
//
//    static let event = WebhookEvent(
//        eventType: .prOpened,
//        repoName: "instantish / instantish",
//        number: 1580,
//        title: "Updated next.JS to v10 & Removed `server.js` & Removed unused dependencies",
//        description: "@richardrobinson0924 created this pull request",
//        avatarUrl: URL(string: "https://avatars3.githubusercontent.com/u/16073505?s=400&u=ca79b02893d6e10fab35e3ba1e593115da64e7ac&v=4")!,
//        timestamp: Date().addingTimeInterval(-300),
//        url: URL(string: "https://www.apple.com")!
//    )
//
//    static let events: [CellData] = [
//        CellData(event: event, avatarData: data),
//        CellData(event: event, avatarData: data),
//        CellData(event: event, avatarData: data)
//    ]
//
//    static var previews: some View {
//        Group {
//            EntryView(events: events)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//
//            EntryView(events: events)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
//
//            EntryView(events: events)
//                .previewContext(WidgetPreviewContext(family: .systemLarge))
//        }
//    }
//}
