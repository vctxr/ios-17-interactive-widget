//
//  DemoWidget.swift
//  DemoWidget
//
//  Created by victor.cuaca on 03/09/23.
//

import WidgetKit
import SwiftUI

// MARK: - Provider

struct Provider: TimelineProvider {
    private let userClient: UserClient = .live
    
    func placeholder(in context: Context) -> UserEntry {
        UserEntry(date: .now, users: .templates)
    }

    func getSnapshot(in context: Context, completion: @escaping (UserEntry) -> ()) {
        guard !context.isPreview else {
            let entry = UserEntry(date: .now, users: .templates)
            completion(entry)
            return
        }

        Task {
            do {
                let users = try await getUsers()
                let entry = UserEntry(date: .now, users: users)
                completion(entry)
            } catch {
                let entry = placeholder(in: context)
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!

            do {
                let users = try await getUsers()
                let entry = UserEntry(date: .now, users: users)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            } catch {
                let entry = placeholder(in: context)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }
    }
    
    private func getUsers() async throws -> [User] {
        let users = try await userClient.getUsers()
        switch getFilterType() {
        case 1:
            return Array(users[0...2])
        case 2:
            return Array(users[3...5])
        case 3:
            return Array(users[6...8])
        default:
            return Array(users[0...2])
        }
    }
    
    private func getFilterType() -> Int {
        UserDefaults.standard.integer(forKey: "filterType")
    }
}

// MARK: - Entry

struct UserEntry: TimelineEntry {
    let date: Date
    let users: [User]
}

// MARK: - Widget View

struct DemoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Filter type")
            HStack {
                ForEach(1..<4) { filterType in
                    Button(intent: FilterIntent(filterType: filterType)) {
                        Text("\(filterType)")
                            .fontDesign(.monospaced)
                    }
                }
            }
            
            HStack {
                Text("Name")
                Spacer()
                Text("Username")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            ForEach(entry.users) { user in
                Spacer()
                HStack {
                    Text(user.name)
                    Spacer()
                    Text(user.username)
                }
                .font(.subheadline)
                Spacer()
            }
            .invalidatableContent()
            
            HStack {
                Text("Time:")
                Text(entry.date, style: .time)
            }
            .font(.footnote)
        }
    }
}

// MARK: - Widget

struct DemoWidget: Widget {
    let kind: String = "DemoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DemoWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DemoWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemLarge])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

// MARK: - Preview

#Preview(as: .systemLarge) {
    DemoWidget()
} timeline: {
    UserEntry(date: .now, users: .templates.shuffled())
    UserEntry(date: .now, users: .templates.shuffled())
}

#Preview(as: .systemLarge) {
    DemoWidget()
} timelineProvider: {
    Provider()
}
