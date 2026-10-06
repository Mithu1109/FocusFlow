//
//  SubjectBreakdownCardView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI

struct SubjectBreakdownCardView: View {
    let breakdownItems: [SubjectBreakdownItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Subject Breakdown")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Distribution of focus time across modules")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Text("\(breakdownItems.count) Modules")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(FocusFlowTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FocusFlowTheme.primary.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            if breakdownItems.isEmpty {
                Text("Log your first Pomodoro session to see subject analytics.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 10)
            } else {
                VStack(spacing: 14) {
                    ForEach(breakdownItems) { item in
                        VStack(spacing: 6) {
                            // Label row
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: item.iconName)
                                        .font(.system(size: 12))
                                        .foregroundColor(item.color)
                                        .frame(width: 20, height: 20)
                                        .background(item.color.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                    
                                    Text(item.subjectName)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Text("\(String(format: "%.1f", item.hours))h")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text("(\(Int(item.percentage))%)")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Visual Progress Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.12))
                                        .frame(height: 7)
                                    
                                    Capsule()
                                        .fill(item.color)
                                        .frame(width: geo.size.width * CGFloat(min(item.percentage / 100.0, 1.0)), height: 7)
                                }
                            }
                            .frame(height: 7)
                        }
                    }
                }
            }
        }
        .padding(18)
        .focusFlowCard()
    }
}
