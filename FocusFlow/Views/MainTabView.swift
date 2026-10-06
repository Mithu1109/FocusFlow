//
//  MainTabView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var pomodoroViewModel = PomodoroViewModel()
    @State private var isShowingSettingsSheet: Bool = false
    
    @AppStorage("focusFlow_theme") private var appTheme: AppThemeMode = .system
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Dashboard Tab
            DashboardView(
                onStartFocusSession: { task in
                    pomodoroViewModel.selectedTask = task
                    pomodoroViewModel.selectedSubject = task.unwrappedSubject
                    pomodoroViewModel.applyRecommendation(
                        subject: task.unwrappedSubject,
                        minutes: max(Int(task.estimatedMinutes), 25)
                    )
                    withAnimation {
                        selectedTab = 1
                    }
                },
                onOpenSettings: {
                    isShowingSettingsSheet = true
                }
            )
            .tabItem {
                Label("Dashboard", systemImage: "square.grid.2x2.fill")
            }
            .tag(0)
            
            // Tab 2: Pomodoro Focus Session Tab
            PomodoroView(viewModel: pomodoroViewModel)
                .tabItem {
                    Label("Focus Timer", systemImage: "timer")
                }
                .tag(1)
            
            // Tab 3: Progress & AI Insights Tab
            ProgressInsightsView(
                onStartRecommendedSession: { subject, minutes in
                    pomodoroViewModel.applyRecommendation(subject: subject, minutes: minutes)
                    withAnimation {
                        selectedTab = 1
                    }
                }
            )
            .tabItem {
                Label("Insights", systemImage: "chart.bar.xaxis")
            }
            .tag(2)
        }
        .accentColor(FocusFlowTheme.primary)
        .preferredColorScheme(appTheme.colorScheme)
        .sheet(isPresented: $isShowingSettingsSheet) {
            SettingsView()
                .preferredColorScheme(appTheme.colorScheme)
        }
    }
}
