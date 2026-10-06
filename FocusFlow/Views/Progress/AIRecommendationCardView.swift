//
//  AIRecommendationCardView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI

struct AIRecommendationCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let recommendation: StudyRecommendation
    let onStartRecommendedSession: ((String, Int) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header: Core ML Badge
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [FocusFlowTheme.primary, FocusFlowTheme.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Core ML Study Intelligence")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(FocusFlowTheme.text(for: colorScheme))
                        Text("Trained on historical study session logs")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(FocusFlowTheme.textSecondary(for: colorScheme))
                    }
                }
                
                Spacer()
                
                // Confidence badge
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                    Text("\(Int(recommendation.confidenceScore * 100))% Match")
                        .font(.system(size: 11, weight: .heavy))
                }
                .foregroundColor(FocusFlowTheme.primary)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(FocusFlowTheme.primary.opacity(colorScheme == .dark ? 0.22 : 0.12))
                .clipShape(Capsule())
            }
            
            // Smart Prompt Quote Box
            VStack(alignment: .leading, spacing: 8) {
                Text(recommendation.smartPrompt)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(FocusFlowTheme.text(for: colorScheme))
                    .lineSpacing(3)
                
                Text(recommendation.reasoningDetail)
                    .font(.system(size: 12))
                    .foregroundColor(FocusFlowTheme.textSecondary(for: colorScheme))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(FocusFlowTheme.aiPromptBoxBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(FocusFlowTheme.primary.opacity(colorScheme == .dark ? 0.35 : 0.2), lineWidth: 1)
            )
            
            // Quick recommendation badges
            HStack(spacing: 10) {
                HStack(spacing: 5) {
                    Image(systemName: "clock.badge.checkmark.fill")
                        .font(.system(size: 11))
                        .foregroundColor(FocusFlowTheme.primary)
                    Text("Peak: \(recommendation.formattedPeakTime)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(FocusFlowTheme.text(for: colorScheme))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(FocusFlowTheme.chipBackground(for: colorScheme))
                .clipShape(Capsule())
                
                HStack(spacing: 5) {
                    Image(systemName: "timer")
                        .font(.system(size: 11))
                        .foregroundColor(FocusFlowTheme.cyan)
                    Text("Duration: \(recommendation.recommendedDurationMinutes) min")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(FocusFlowTheme.text(for: colorScheme))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(FocusFlowTheme.chipBackground(for: colorScheme))
                .clipShape(Capsule())
                
                Spacer()
            }
            
            // Call to action button: "Start Recommended Session"
            Button(action: {
                HapticManager.shared.medium()
                onStartRecommendedSession?(
                    recommendation.recommendedSubject,
                    recommendation.recommendedDurationMinutes
                )
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Start Recommended Session")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(FocusFlowTheme.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: FocusFlowTheme.primary.opacity(0.3), radius: 6, x: 0, y: 3)
            }
        }
        .padding(18)
        .background(FocusFlowTheme.aiCardGradient(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(FocusFlowTheme.primary.opacity(colorScheme == .dark ? 0.4 : 0.35), lineWidth: 1.5)
        )
        .shadow(
            color: colorScheme == .dark ? Color.black.opacity(0.35) : FocusFlowTheme.primary.opacity(0.12),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}
