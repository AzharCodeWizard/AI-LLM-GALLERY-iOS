//
//  GalleryView.swift
//  AI LLM GALLERY
//
//  Main gallery screen with capability cards, category filtering, and feature highlights.
//

import SwiftUI

struct GalleryView: View {
    let onCapabilityTap: (AiCapability) -> Void
    let onSettingsTap: () -> Void
    let onQuizTap: () -> Void
    let onStoryTap: () -> Void

    @StateObject private var viewModel = GalleryViewModel()
    @StateObject private var llmManager = LlmInferenceManager.shared
    @State private var animateCards = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // ── Header ──
                headerSection

                // ── Model Status Card ──
                modelStatusCard
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                // ── Innovative Features Row ──
                featuresSection
                    .padding(.bottom, 20)

                // ── Category Filter ──
                CategoryChips(
                    selectedCategory: $viewModel.selectedCategory,
                    categories: CapabilityCategory.allCases
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                // ── Capability Cards Grid ──
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(Array(viewModel.filteredCapabilities.enumerated()), id: \.element.id) { index, capability in
                        CapabilityCard(capability: capability)
                            .onTapGesture { onCapabilityTap(capability) }
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : 20)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                    .delay(Double(index) * 0.07),
                                value: animateCards
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color.appBackground)
        .navigationTitle("AI Gallery")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateCards = true
            }

            // Auto-init: scan for downloaded models first, fallback to mock
            if !llmManager.isInitialized {
                Task {
                    let models = llmManager.getDownloadedModels()
                    if let firstModel = models.first {
                        await llmManager.initialize(modelPath: firstModel.path)
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Explore AI")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appPrimary)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            Text("On-Device Intelligence")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.appOnSurfaceVariant)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Model Status Card

    private var modelStatusCard: some View {
        HStack(spacing: 14) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(llmManager.isInitialized ? AppColors.success.opacity(0.15) : Color.appSurfaceVariant)
                    .frame(width: 44, height: 44)

                Image(systemName: llmManager.isInitialized ? "cpu" : "arrow.down.circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(llmManager.isInitialized ? AppColors.success : .appOnSurfaceVariant)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(llmManager.isInitialized ? "Engine Active" : "No Model Loaded")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.appOnSurface)

                Text(llmManager.activeModelName)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.appOnSurfaceVariant)
                    .lineLimit(1)
            }

            Spacer()

            if !llmManager.isInitialized {
                Button(action: onSettingsTap) {
                    Text("Setup")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.appOnPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.appPrimary)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.appSurface)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Innovative Features")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.appOnSurfaceVariant)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // AI Quizzes Card
                    featureCard(
                        title: "AI Quizzes",
                        subtitle: "Generate & play quizzes",
                        icon: "brain.head.profile",
                        gradient: [AppColors.quizGradientStart, AppColors.quizGradientEnd],
                        action: onQuizTap
                    )

                    // Audio Scripts Card
                    featureCard(
                        title: "Audio Scripts",
                        subtitle: "Stories, poems & TTS",
                        icon: "waveform",
                        gradient: [AppColors.gradientMultimodalStart, AppColors.gradientMultimodalEnd],
                        action: onStoryTap
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func featureCard(
        title: String,
        subtitle: String,
        icon: String,
        gradient: [Color],
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(18)
            .frame(width: 260)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: gradient[0].opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}
