//
//  DashboardView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("focusFlow_theme") private var appTheme: AppThemeMode = .system
    @AppStorage("focusFlow_userName") private var userName: String = "Mithula"
    @AppStorage("focusFlow_dailyGoalHours") private var dailyGoalHours: Double = 3.5
    
    @StateObject private var viewModel = DashboardViewModel()
    
    @FetchRequest(
        entity: TaskItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \TaskItem.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \TaskItem.dueDate, ascending: true)
        ],
        animation: .spring()
    )
    private var tasks: FetchedResults<TaskItem>
    
    @FetchRequest(
        entity: StudySession.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySession.startTime, ascending: false)],
        animation: .default
    )
    private var sessions: FetchedResults<StudySession>
    
    @FetchRequest(
        entity: UserProfile.entity(),
        sortDescriptors: [],
        animation: .default
    )
    private var profiles: FetchedResults<UserProfile>
    
    // Binding to switch tab to Pomodoro with a selected task
    var onStartFocusSession: ((TaskItem) -> Void)?
    var onOpenSettings: (() -> Void)?
    
    var currentStreak: Int {
        profiles.first?.safeStreakCount ?? 5
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // 1. Welcome Header
                        welcomeHeader
                        
                        // 2. Streak & Daily Goal Card
                        StreakCardView(
                            streakCount: currentStreak,
                            motivationalMessage: viewModel.motivationalMessage,
                            todayMinutes: viewModel.calculateTodayStudyMinutes(sessions: Array(sessions)),
                            completedTasksCount: tasks.filter { $0.isCompleted }.count,
                            dailyGoalHours: dailyGoalHours
                        )
                        
                        // 3. Quick Stats Row
                        quickStatsRow
                        
                        // 4. Today's Tasks Section Header & Filter
                        tasksSectionHeader
                        
                        // 5. Tasks List
                        tasksListView
                        
                        // Bottom spacing for tab bar and FAB
                        Spacer().frame(height: 70)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                }
                
                // Floating Add Task Button
                Button(action: {
                    HapticManager.shared.light()
                    viewModel.isShowingAddTaskSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                        Text("Add Task")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(FocusFlowTheme.primaryGradient)
                    .clipShape(Capsule())
                    .shadow(color: FocusFlowTheme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .focusFlowBackground()
            .sheet(isPresented: $viewModel.isShowingAddTaskSheet) {
                AddTaskSheet(viewModel: viewModel)
                    .preferredColorScheme(appTheme.colorScheme)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        HStack(alignment: .center) {
            // App Logo Mark & Greeting
            HStack(spacing: 12) {
                Image("AppIconMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: FocusFlowTheme.primary.opacity(0.2), radius: 5, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.greeting), \(userName)!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(viewModel.formattedDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Settings Button
            Button(action: {
                HapticManager.shared.light()
                onOpenSettings?()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(FocusFlowTheme.textSecondary(for: colorScheme))
                    .frame(width: 38, height: 38)
                    .background(FocusFlowTheme.card(for: colorScheme))
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(FocusFlowTheme.cardBorder(for: colorScheme), lineWidth: 1)
                    )
                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Quick Stats Row
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            let pendingCount = tasks.filter { !$0.isCompleted }.count
            let completedCount = tasks.filter { $0.isCompleted }.count
            let todayMinutes = viewModel.calculateTodayStudyMinutes(sessions: Array(sessions))
            
            statBox(
                title: "Pending",
                value: "\(pendingCount)",
                icon: "list.bullet.clipboard",
                color: FocusFlowTheme.primary
            )
            
            statBox(
                title: "Completed",
                value: "\(completedCount)",
                icon: "checkmark.circle.fill",
                color: FocusFlowTheme.success
            )
            
            statBox(
                title: "Today Focus",
                value: "\(todayMinutes)m",
                icon: "timer",
                color: FocusFlowTheme.purple
            )
        }
    }
    
    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .focusFlowCard(cornerRadius: 14)
    }
    
    // MARK: - Tasks Section Header & Filter
    private var tasksSectionHeader: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's Tasks")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Swipe right/left to complete or manage")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // Segmented Filter
            HStack(spacing: 6) {
                ForEach(TaskFilter.allCases) { filter in
                    Button(action: {
                        HapticManager.shared.selection()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedFilter = filter
                        }
                    }) {
                        Text(filter.rawValue)
                            .font(.system(size: 12, weight: viewModel.selectedFilter == filter ? .bold : .medium))
                            .foregroundColor(
                                viewModel.selectedFilter == filter ?
                                .white :
                                FocusFlowTheme.textSecondary(for: colorScheme)
                            )
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                viewModel.selectedFilter == filter ?
                                FocusFlowTheme.primary : Color.clear
                            )
                            .clipShape(Capsule())
                    }
                }
                Spacer()
            }
            .padding(4)
            .background(FocusFlowTheme.card(for: colorScheme))
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(FocusFlowTheme.cardBorder(for: colorScheme), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Tasks List View
    private var tasksListView: some View {
        let filtered = viewModel.filteredTasks(tasks: Array(tasks))
        
        return Group {
            if filtered.isEmpty {
                emptyTasksState
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(filtered) { task in
                        TaskRowView(
                            task: task,
                            onToggleComplete: {
                                viewModel.toggleTaskCompletion(task: task, context: viewContext)
                            },
                            onDelete: {
                                viewModel.deleteTask(task: task, context: viewContext)
                            },
                            onSelectForFocus: {
                                onStartFocusSession?(task)
                            }
                        )
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.toggleTaskCompletion(task: task, context: viewContext)
                            } label: {
                                Label(
                                    task.isCompleted ? "Unmark" : "Complete",
                                    systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                                )
                            }
                            .tint(task.isCompleted ? .orange : FocusFlowTheme.success)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.deleteTask(task: task, context: viewContext)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var emptyTasksState: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundColor(FocusFlowTheme.primary.opacity(0.4))
                .padding(.top, 10)
            
            Text(viewModel.selectedFilter == .completed ? "No completed tasks yet" : "All caught up!")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Text(
                viewModel.selectedFilter == .completed ?
                "Complete a task from your pending list to see it here." :
                "You have no tasks pending in this category. Enjoy your study momentum or add a new assignment."
            )
            .font(.system(size: 13))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .focusFlowCard()
    }
}
