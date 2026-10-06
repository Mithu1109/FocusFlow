//
//  ProgressInsightsView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData

struct ProgressInsightsView: View {
    @AppStorage("focusFlow_dailyGoalHours") private var dailyGoalHours: Double = 3.5
    
    @StateObject private var viewModel = ProgressAnalyticsViewModel()
    
    @FetchRequest(
        entity: StudySession.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySession.startTime, ascending: false)],
        animation: .default
    )
    private var sessions: FetchedResults<StudySession>
    
    @FetchRequest(
        entity: TaskItem.entity(),
        sortDescriptors: [],
        animation: .default
    )
    private var tasks: FetchedResults<TaskItem>
    
    var onStartRecommendedSession: ((String, Int) -> Void)?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Metric Overview Cards
                    overviewMetricsGrid
                    
                    // 2. Core ML Recommendation Card
                    let recommendation = viewModel.getRecommendation(
                        sessions: Array(sessions),
                        tasks: Array(tasks)
                    )
                    AIRecommendationCardView(
                        recommendation: recommendation,
                        onStartRecommendedSession: onStartRecommendedSession
                    )
                    
                    // 3. Weekly Swift Chart
                    let weeklyData = viewModel.calculateWeeklyData(sessions: Array(sessions))
                    WeeklyStudyChartView(
                        weeklyData: weeklyData,
                        dailyGoalHours: dailyGoalHours,
                        selectedDay: $viewModel.selectedDayData
                    )
                    
                    // 4. Subject Breakdown
                    let breakdown = viewModel.calculateSubjectBreakdown(sessions: Array(sessions))
                    SubjectBreakdownCardView(breakdownItems: breakdown)
                    
                    Spacer().frame(height: 50)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
            }
            .navigationTitle("Analytics & AI Insights")
            .navigationBarTitleDisplayMode(.inline)
            .focusFlowBackground()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Overview Metrics Grid
    private var overviewMetricsGrid: some View {
        let totalHours = viewModel.totalStudyHoursThisWeek(sessions: Array(sessions))
        let dailyAvg = viewModel.dailyAverageHours(sessions: Array(sessions))
        let sessionCount = viewModel.totalSessionsCount(sessions: Array(sessions))
        let completionRate = viewModel.completionRate(sessions: Array(sessions))
        
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricCard(
                title: "Weekly Focus",
                value: "\(String(format: "%.1f", totalHours)) hrs",
                subtitle: "Past 7 days",
                icon: "chart.bar.fill",
                color: FocusFlowTheme.primary
            )
            
            metricCard(
                title: "Daily Average",
                value: "\(String(format: "%.1f", dailyAvg))h / day",
                subtitle: "Goal: \(String(format: "%.1f", dailyGoalHours))h",
                icon: "hourglass",
                color: FocusFlowTheme.cyan
            )
            
            metricCard(
                title: "Sessions Logged",
                value: "\(sessionCount)",
                subtitle: "Total Pomodoros",
                icon: "checkmark.circle.badge.questionmark",
                color: FocusFlowTheme.purple
            )
            
            metricCard(
                title: "Completion Rate",
                value: "\(completionRate)%",
                subtitle: "Consistency score",
                icon: "bolt.heart.fill",
                color: FocusFlowTheme.success
            )
        }
    }
    
    private func metricCard(title: String, value: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.8))
        }
        .padding(14)
        .focusFlowCard(cornerRadius: 14)
    }
}
