//
//  QuizListView.swift
//  AI LLM GALLERY
//

import SwiftUI
import SwiftData

struct QuizListView: View {
    let onBack: () -> Void
    let onQuizPlay: (String) -> Void

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = QuizViewModel()
    @State private var newTopic = ""

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // ── Generator Card ──
                generatorCard
                    .padding(16)

                // ── Quiz List ──
                if viewModel.quizzes.isEmpty && !viewModel.isGenerating {
                    emptyState
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.quizzes, id: \.persistentModelID) { quiz in
                            quizCard(quiz: quiz)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle("AI Quizzes")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    // MARK: - Generator Card

    private var generatorCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.appPrimaryContainer)
                        .frame(width: 44, height: 44)

                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.appOnPrimaryContainer)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Create Magic")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appOnSurface)

                    Text("Generate a quiz on any topic with on-device AI")
                        .font(.system(size: 12))
                        .foregroundColor(.appOnSurfaceVariant)
                }
            }

            TextField("e.g. Space Exploration, Biology", text: $newTopic)
                .font(.system(size: 15))
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.appSurface.opacity(0.5))
                        .stroke(Color.appOutline.opacity(0.3), lineWidth: 1)
                )
                .disabled(viewModel.isGenerating)

            if let error = viewModel.error {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.appError)
            }

            HStack {
                Spacer()
                Button(action: {
                    if !newTopic.isEmpty {
                        viewModel.generateQuiz(topic: newTopic)
                        newTopic = ""
                    }
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                            Text("Generating...")
                                .font(.system(size: 14, weight: .semibold))
                        } else {
                            Text("Generate Quiz")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundColor(.appOnPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        (!viewModel.isGenerating && !newTopic.isEmpty)
                            ? Color.appPrimary
                            : Color.appOnSurface.opacity(0.12)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(viewModel.isGenerating || newTopic.isEmpty)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.appSurfaceVariant.opacity(0.4))
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "graduationcap")
                .font(.system(size: 48))
                .foregroundColor(.appOnSurfaceVariant.opacity(0.3))

            Text("No quizzes yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.appOnSurfaceVariant)

            Text("Generate your first AI quiz above!")
                .font(.system(size: 13))
                .foregroundColor(.appOnSurfaceVariant.opacity(0.6))
        }
        .padding(48)
    }

    // MARK: - Quiz Card

    private func quizCard(quiz: Quiz) -> some View {
        Button(action: {
            onQuizPlay(quiz.persistentModelID.hashValue.description)
        }) {
            HStack(spacing: 14) {
                // Icon badge
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.appPrimaryContainer)
                        .frame(width: 52, height: 52)

                    Image(systemName: "play.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.appOnPrimaryContainer)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appOnSurface)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        Text("\(quiz.questions.count) Qs")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.appOnPrimaryContainer)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.appPrimaryContainer)
                            )

                        Text(quiz.timestamp.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 11))
                            .foregroundColor(.appOnSurfaceVariant)
                    }
                }

                Spacer()

                Button(action: { viewModel.deleteQuiz(quiz) }) {
                    Image(systemName: "trash")
                        .font(.system(size: 15))
                        .foregroundColor(.appError.opacity(0.7))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appSurface)
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
