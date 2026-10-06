//
//  StreakCardView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI

struct StreakCardView: View {
    let streakCount: Int
    let motivationalMessage: String
    let todayMinutes: Int
    let completedTasksCount: Int
    let dailyGoalHours: Double
    
    var goalProgress: Double {
        let goalMinutes = max(dailyGoalHours * 60, 1.0)
        return min(Double(todayMinutes) / goalMinutes, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Top row: Streak flame & counter + Today's quick goal ring
            HStack(alignment: .center, spacing: 14) {
                // Streak Flame Badge
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FF6B35"), Color(hex: "F59E0B")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                            .shadow(color: Color(hex: "FF6B35").opacity(0.4), radius: 8, x: 0, y: 3)
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(streakCount)")
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundColor(FocusFlowTheme.primary)
                            Text("Days Streak")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        Text("Active Study Momentum")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Mini Goal Progress
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(FocusFlowTheme.primary.opacity(0.15), lineWidth: 5)
                            .frame(width: 44, height: 44)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(goalProgress))
                            .stroke(
                                FocusFlowTheme.primaryGradient,
                                style: StrokeStyle(lineWidth: 5, lineCap: .round)
                            )
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: goalProgress)
                        
                        Text("\(Int(goalProgress * 100))%")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(todayMinutes) min")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("of \(String(format: "%.1f", dailyGoalHours))h goal")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
                .opacity(0.5)
            
            // Motivational Quote
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(FocusFlowTheme.primary)
                
                Text(motivationalMessage)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .italic()
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(18)
        .focusFlowCard()
    }
}
