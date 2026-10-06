//
//  FocusFlowApp.swift
//  FocusFlow (Smart Study Planner)
//
//  Created for FocusFlow.
//

import SwiftUI
import CoreData

@main
struct FocusFlowApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("focusFlow_theme") private var appTheme: AppThemeMode = .system

    init() {
        // Check and prepare notification manager
        NotificationManager.shared.checkAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(appTheme.colorScheme)
        }
    }
}
