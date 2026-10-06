//
//  WeeklyStudyChartView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import Charts

struct WeeklyStudyChartView: View {
    let weeklyData: [DayStudyData]
    let dailyGoalHours: Double
    @Binding var selectedDay: DayStudyData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekly Study Hours")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Hours logged across the past 7 days")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Target Goal Legend
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: "F59E0B"))
                        .frame(width: 8, height: 8)
                    Text("Goal (\(String(format: "%.1f", dailyGoalHours))h)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
            
            // Swift Charts Chart
            Chart {
                // Goal Rule Line
                RuleMark(
                    y: .value("Daily Goal", dailyGoalHours)
                )
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .foregroundStyle(Color(hex: "F59E0B").opacity(0.8))
                
                // Bars per day
                ForEach(weeklyData) { item in
                    BarMark(
                        x: .value("Day", item.dayName),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(
                        item.isToday ?
                        LinearGradient(
                            colors: [FocusFlowTheme.primary, FocusFlowTheme.cyan],
                            startPoint: .bottom,
                            endPoint: .top
                        ) :
                        LinearGradient(
                            colors: [FocusFlowTheme.primary.opacity(0.65), FocusFlowTheme.primary.opacity(0.9)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(8)
                }
            }
            .frame(height: 190)
            .chartYScale(domain: 0...max(dailyGoalHours + 1.5, (weeklyData.map { $0.hours }.max() ?? 3.0) + 1.0))
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let h = value.as(Double.self) {
                            Text("\(Int(h))h")
                                .font(.system(size: 10))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let day = value.as(String.self) {
                            let isCurrentDay = weeklyData.first(where: { $0.dayName == day })?.isToday == true
                            Text(day)
                                .font(.system(size: 11, weight: isCurrentDay ? .bold : .regular))
                                .foregroundColor(isCurrentDay ? FocusFlowTheme.primary : .secondary)
                        }
                    }
                }
            }
            
            // Selected or Today Highlight Details
            let currentDayData = selectedDay ?? weeklyData.first(where: { $0.isToday })
            if let active = currentDayData {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(FocusFlowTheme.primary)
                    Text("\(active.dayName): \(String(format: "%.1f", active.hours)) hours studied across \(active.sessionCount) sessions")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(FocusFlowTheme.primary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(18)
        .focusFlowCard()
    }
}
