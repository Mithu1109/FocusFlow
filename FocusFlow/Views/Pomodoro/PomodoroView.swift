//
//  PomodoroView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData

struct PomodoroView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("focusFlow_theme") private var appTheme: AppThemeMode = .system
    @ObservedObject var viewModel: PomodoroViewModel
    
    @State private var isShowingCustomDurationSheet: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 1. Header & Subject Selector
                    subjectPickerSection
                    
                    // 2. Active Linked Task (if any)
                    if let task = viewModel.selectedTask {
                        linkedTaskBanner(task: task)
                    }
                    
                    // 3. Preset Mode Selector
                    presetModeSelector
                    
                    // 4. Large Animated Circular Timer
                    CircularTimerProgressView(
                        progress: viewModel.progress,
                        formattedTime: viewModel.formattedTime,
                        timerState: viewModel.timerState,
                        modeColor: viewModel.selectedMode.themeColor
                    )
                    .padding(.vertical, 8)
                    
                    // 5. Timer Action Controls (Start / Pause / Resume / End)
                    controlButtonsSection
                    
                    // 6. Ambient Focus Sound Picker
                    ambientSoundSection
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
            }
            .navigationTitle("Focus Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .focusFlowBackground()
            .sheet(isPresented: $viewModel.isShowingCompletionSheet) {
                SessionCompletionSheet(viewModel: viewModel)
                    .preferredColorScheme(appTheme.colorScheme)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Subject Picker Section
    private var subjectPickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Academic Subject")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SubjectModule.defaultModules) { module in
                        let isSelected = (viewModel.selectedSubject == module.name)
                        Button(action: {
                            HapticManager.shared.selection()
                            viewModel.selectedSubject = module.name
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: module.iconName)
                                    .font(.system(size: 12, weight: .semibold))
                                Text(module.name)
                                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                            }
                            .foregroundColor(isSelected ? .white : FocusFlowTheme.text(for: colorScheme))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                isSelected ?
                                module.color :
                                FocusFlowTheme.secondaryCard(for: colorScheme)
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? Color.clear : FocusFlowTheme.cardBorder(for: colorScheme), lineWidth: 1)
                            )
                            .shadow(color: isSelected ? module.color.opacity(0.3) : (colorScheme == .dark ? Color.black.opacity(0.25) : Color.black.opacity(0.03)), radius: 6, x: 0, y: 2)
                        }
                        .disabled(viewModel.timerState == .running)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
    
    // MARK: - Linked Task Banner
    private func linkedTaskBanner(task: TaskItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "link.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(FocusFlowTheme.primary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Studying for Task:")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(task.unwrappedTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.selectedTask = nil
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(FocusFlowTheme.primary.opacity(colorScheme == .dark ? 0.18 : 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Preset Mode Selector
    private var presetModeSelector: some View {
        HStack(spacing: 8) {
            ForEach(PomodoroMode.allCases) { mode in
                let isSelected = (viewModel.selectedMode == mode)
                Button(action: {
                    HapticManager.shared.selection()
                    viewModel.selectedMode = mode
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: mode.iconName)
                            .font(.system(size: 14, weight: .bold))
                        Text(mode.shortTitle)
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(isSelected ? .white : FocusFlowTheme.textSecondary(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        isSelected ?
                        mode.themeColor :
                        FocusFlowTheme.secondaryCard(for: colorScheme)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.clear : FocusFlowTheme.cardBorder(for: colorScheme), lineWidth: 1)
                    )
                    .shadow(color: isSelected ? mode.themeColor.opacity(0.3) : (colorScheme == .dark ? Color.black.opacity(0.25) : Color.black.opacity(0.03)), radius: 4, x: 0, y: 2)
                }
                .disabled(viewModel.timerState == .running)
            }
        }
    }
    
    // MARK: - Controls & State Buttons (Start, Pause, Resume, End)
    private var controlButtonsSection: some View {
        HStack(spacing: 16) {
            switch viewModel.timerState {
            case .idle:
                // Start Session Button
                Button(action: {
                    viewModel.startTimer()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("Start Session")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(FocusFlowTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: FocusFlowTheme.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                
            case .running:
                // Pause Button
                Button(action: {
                    viewModel.pauseTimer()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "pause.fill")
                        Text("Pause")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(FocusFlowTheme.text(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(FocusFlowTheme.card(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(FocusFlowTheme.cardBorder(for: colorScheme), lineWidth: 1)
                    )
                }
                
                // End Session Button
                Button(action: {
                    viewModel.endSessionEarly(context: viewContext)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                        Text("End Session")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(FocusFlowTheme.highPriority)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(FocusFlowTheme.highPriority.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                
            case .paused:
                // Resume Button
                Button(action: {
                    viewModel.resumeTimer()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Resume")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(FocusFlowTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: FocusFlowTheme.primary.opacity(0.35), radius: 8, x: 0, y: 4)
                }
                
                // Reset Button
                Button(action: {
                    viewModel.resetTimer()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(FocusFlowTheme.textSecondary(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(FocusFlowTheme.card(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(FocusFlowTheme.cardBorder(for: colorScheme), lineWidth: 1)
                    )
                }
                
            case .completed:
                Button(action: {
                    viewModel.resetTimerDuration()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Start Another")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(FocusFlowTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Ambient Sound Section
    private var ambientSoundSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Focus Background Audio")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                ForEach(AmbientSound.allCases) { sound in
                    let isSelected = (viewModel.selectedSound == sound)
                    Button(action: {
                        HapticManager.shared.selection()
                        viewModel.selectedSound = sound
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: sound.icon)
                                .font(.system(size: 13))
                            Text(sound.rawValue)
                                .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                                .lineLimit(1)
                        }
                        .foregroundColor(isSelected ? FocusFlowTheme.primary : FocusFlowTheme.textSecondary(for: colorScheme))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            isSelected ?
                            FocusFlowTheme.primary.opacity(colorScheme == .dark ? 0.22 : 0.12) :
                            FocusFlowTheme.secondaryCard(for: colorScheme)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? FocusFlowTheme.primary : FocusFlowTheme.cardBorder(for: colorScheme), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}
