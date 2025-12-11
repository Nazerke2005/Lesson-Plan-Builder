//
//  labsessionApp.swift
//  labsession
//
//  Created by Nazerke Turgанбек on 05.12.2025.
//

import SwiftUI
import SwiftData
import Combine

final class AppThemeManager: ObservableObject {
    // 0 system, 1 light, 2 dark
    @AppStorage("app.theme") var theme: Int = 0 {
        didSet { objectWillChange.send() }
    }
    // "kk", "ru", "en"
    @AppStorage("app.language") var language: String = "kk" {
        didSet { objectWillChange.send() }
    }

    var colorScheme: ColorScheme? {
        switch theme {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var locale: Locale {
        switch language {
        case "kk": return Locale(identifier: "kk")
        case "ru": return Locale(identifier: "ru")
        case "en": return Locale(identifier: "en")
        default:   return Locale(identifier: language)
        }
    }
}

@main
struct labsessionApp: App {
    @StateObject private var themeManager = AppThemeManager()
    @StateObject private var profileManager = ProfileManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Lesson.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: {error}")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(profileManager)
                .preferredColorScheme(themeManager.colorScheme)
                .environment(\.locale, themeManager.locale)
                .id(themeManager.language)
        }
        .modelContainer(sharedModelContainer)
    }
}
