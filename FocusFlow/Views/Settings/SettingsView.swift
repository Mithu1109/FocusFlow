//
//  SettingsView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - App Branding Banner
                Section {
                    VStack(alignment: .center, spacing: 12) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 75)
                            .padding(.vertical, 4)
                        
                        Text("Smart Study Planner")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                }
                
                // MARK: - Student Profile
                Section(header: Text("Student Profile").font(.system(size: 12, weight: .bold))) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(FocusFlowTheme.primary)
                        TextField("Student Name", text: $viewModel.userName)
                            .font(.system(size: 15))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Daily Focus Goal")
                            Spacer()
                            Text("\(String(format: "%.1f", viewModel.dailyGoalHours)) hours")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(FocusFlowTheme.primary)
                        }
                        Slider(value: $viewModel.dailyGoalHours, in: 1.0...8.0, step: 0.5)
                            .tint(FocusFlowTheme.primary)
                    }
                }
                
                // MARK: - Appearance & Preferences
                Section(header: Text("Appearance & Timer").font(.system(size: 12, weight: .bold))) {
                    Picker("Theme Mode", selection: $viewModel.appTheme) {
                        ForEach(AppThemeMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Default Focus Duration", selection: $viewModel.defaultPomodoroMinutes) {
                        Text("25 Minutes (Short)").tag(25)
                        Text("45 Minutes (Standard)").tag(45)
                        Text("60 Minutes (Deep)").tag(60)
                    }
                }
                
                // MARK: - Local Notifications
                Section(header: Text("Notifications & Reminders").font(.system(size: 12, weight: .bold))) {
                    Toggle(isOn: $viewModel.notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(FocusFlowTheme.purple)
                            Text("Study & Deadline Reminders")
                        }
                    }
                    
                    Button(action: {
                        viewModel.sendTestNotification()
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Send Test Notification Now")
                        }
                        .foregroundColor(FocusFlowTheme.primary)
                    }
                }
                
                // MARK: - Core Data Management
                Section(
                    header: Text("Core Data & Storage").font(.system(size: 12, weight: .bold)),
                    footer: Text("Resetting permanently removes all tasks and logged sessions.")
                ) {
                    Button(action: {
                        viewModel.loadSampleData(context: viewContext)
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Load University Sample Data")
                        }
                        .foregroundColor(FocusFlowTheme.primary)
                    }
                    
                    Button(action: {
                        viewModel.exportData(context: viewContext)
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Study Records (JSON)")
                        }
                        .foregroundColor(.primary)
                    }
                    
                    Button(role: .destructive, action: {
                        viewModel.isShowingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Reset All Data")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                // MARK: - About
                Section(header: Text("About FocusFlow").font(.system(size: 12, weight: .bold))) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Machine Learning")
                        Spacer()
                        Text("Core ML Regression Engine")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Data Framework")
                        Spacer()
                        Text("Apple Core Data + Swift Charts")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings & Customization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(FocusFlowTheme.primary)
                }
            }
            .alert(isPresented: $viewModel.isShowingResetAlert) {
                Alert(
                    title: Text("Reset All Data?"),
                    message: Text("This will remove all task entries and Pomodoro history. This cannot be undone."),
                    primaryButton: .destructive(Text("Reset Everything")) {
                        viewModel.resetData(context: viewContext)
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $viewModel.isShowingExportShareSheet) {
                ShareSheet(activityItems: [viewModel.exportedJSONString])
            }
            .alert(viewModel.alertMessage, isPresented: $viewModel.isShowingAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

// MARK: - UIActivityViewController Wrapper for Export
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
