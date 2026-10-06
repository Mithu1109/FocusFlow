//
//  SettingsViewModel.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData
import Combine

enum AppThemeMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage("focusFlow_userName") var userName: String = "Mithula"
    @AppStorage("focusFlow_theme") var appTheme: AppThemeMode = .system
    @AppStorage("focusFlow_defaultPomodoro") var defaultPomodoroMinutes: Int = 25
    @AppStorage("focusFlow_dailyGoalHours") var dailyGoalHours: Double = 3.5
    @AppStorage("focusFlow_notificationsEnabled") var notificationsEnabled: Bool = true
    
    @Published var isShowingResetAlert: Bool = false
    @Published var isShowingExportShareSheet: Bool = false
    @Published var exportedJSONString: String = ""
    @Published var alertMessage: String = ""
    @Published var isShowingAlert: Bool = false
    
    func resetData(context: NSManagedObjectContext) {
        PersistenceController.shared.resetAllData(context: context)
        HapticManager.shared.warning()
        alertMessage = "All tasks and study records have been reset."
        isShowingAlert = true
    }
    
    func loadSampleData(context: NSManagedObjectContext) {
        PersistenceController.shared.seedUniversitySampleData(context: context)
        HapticManager.shared.success()
        alertMessage = "University courses, tasks, and historical study logs loaded!"
        isShowingAlert = true
    }
    
    func exportData(context: NSManagedObjectContext) {
        let json = PersistenceController.shared.exportDataAsJSON(context: context)
        exportedJSONString = json
        isShowingExportShareSheet = true
        HapticManager.shared.medium()
    }
    
    func sendTestNotification() {
        NotificationManager.shared.sendTestNotification()
        alertMessage = "Test notification scheduled for 2 seconds from now!"
        isShowingAlert = true
    }
}
