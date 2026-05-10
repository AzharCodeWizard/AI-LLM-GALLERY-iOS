//
//  QuizPlayView.swift
//  AI LLM GALLERY
//

import SwiftUI
import SwiftData

struct QuizPlayView: View {
    let quizId: String
    let onBack: () -> Void

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = PlayQuizViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.quiz == nil {
                    VStack(spacing: 16) { ProgressView(); Text("Loading quiz...").font(.system(size: 14)).foregroundColor(.appOnSurfaceVariant) }.frame(maxWidth: .infinity).padding(64)
                } else if viewModel.isFinished {
                    resultsView
                } else if let question = viewModel.currentQuestion {
                    questionView(question: question)
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle(viewModel.quiz?.title ?? "Loading...")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar { ToolbarItem(placement: .topBarLeading) { Button(action: onBack) { Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)).foregroundColor(.appPrimary) } } }
        .onAppear { viewModel.setModelContext(modelContext); viewModel.loadQuiz(quizId: quizId) }
    }

    private func questionView(question: Question) -> some View {
        VStack(spacing: 0) {
            // Progress
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.totalQuestions)").font(.system(size: 14, weight: .bold)).foregroundColor(AppColors.quizGradientStart)
                    Spacer()
                    Text("\(Int(viewModel.progress * 100))%").font(.system(size: 12, weight: .semibold)).foregroundColor(.appOnSurfaceVariant)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5).fill(Color.appSurfaceVariant).frame(height: 10)
                        RoundedRectangle(cornerRadius: 5).fill(LinearGradient(colors: [AppColors.quizGradientStart, AppColors.quizGradientEnd], startPoint: .leading, endPoint: .trailing)).frame(width: geo.size.width * CGFloat(viewModel.progress), height: 10).animation(.spring(response: 0.5, dampingFraction: 0.6), value: viewModel.progress)
                    }
                }.frame(height: 10)
            }.padding(.horizontal, 20).padding(.top, 8)
            Spacer().frame(height: 28)
            // Question card
            Text(question.questionText).font(.system(size: 22, weight: .semibold)).foregroundColor(.appOnSurface).multilineTextAlignment(.center).lineSpacing(4).padding(28).frame(maxWidth: .infinity).background(RoundedRectangle(cornerRadius: 24).fill(LinearGradient(colors: [AppColors.quizGradientStart.opacity(0.08), AppColors.quizGradientEnd.opacity(0.04)], startPoint: .top, endPoint: .bottom)).shadow(color: .black.opacity(0.05), radius: 8, y: 4)).padding(.horizontal, 20)
            Spacer().frame(height: 28)
            // Options
            VStack(spacing: 14) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    optionCard(label: String(Character(UnicodeScalar(65 + index)!)), text: option, index: index, correctIndex: question.correctAnswerIndex)
                }
            }.padding(.horizontal, 20)
            Spacer().frame(height: 32)
            if viewModel.selectedAnswerIndex != nil {
                Button(action: { viewModel.nextQuestion() }) {
                    Text(viewModel.currentQuestionIndex + 1 == viewModel.totalQuestions ? "See Results" : "Next Question").font(.system(size: 17, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(AppColors.quizGradientStart).clipShape(RoundedRectangle(cornerRadius: 16))
                }.padding(.horizontal, 20)
            }
            Spacer().frame(height: 24)
        }
    }

    private func optionCard(label: String, text: String, index: Int, correctIndex: Int) -> some View {
        let hasAnswered = viewModel.selectedAnswerIndex != nil
        let isSelected = viewModel.selectedAnswerIndex == index
        let isCorrect = index == correctIndex
        let bgColor: Color = hasAnswered && isCorrect ? AppColors.success.opacity(0.12) : hasAnswered && isSelected ? AppColors.danger.opacity(0.12) : isSelected ? AppColors.quizGradientStart.opacity(0.1) : Color.appSurfaceVariant.opacity(0.5)
        let borderColor: Color = hasAnswered && isCorrect ? AppColors.success : hasAnswered && isSelected && !isCorrect ? AppColors.danger : isSelected ? AppColors.quizGradientStart : Color.appOutline.opacity(0.3)
        let badgeColor: Color = hasAnswered && isCorrect ? AppColors.success : hasAnswered && isSelected && !isCorrect ? AppColors.danger : isSelected ? AppColors.quizGradientStart : AppColors.quizGradientStart.opacity(0.15)
        let badgeText: Color = (hasAnswered && isCorrect) || (hasAnswered && isSelected) || isSelected ? .white : AppColors.quizGradientStart

        return Button(action: { if !hasAnswered { viewModel.submitAnswer(index) } }) {
            HStack(spacing: 14) {
                ZStack { Circle().fill(badgeColor).frame(width: 36, height: 36); Text(label).font(.system(size: 14, weight: .bold)).foregroundColor(badgeText) }
                Text(text).font(.system(size: 16, weight: isSelected || (hasAnswered && isCorrect) ? .semibold : .regular)).foregroundColor(.appOnSurface).frame(maxWidth: .infinity, alignment: .leading)
                if hasAnswered && isCorrect { Image(systemName: "checkmark.circle.fill").font(.system(size: 22)).foregroundColor(AppColors.success) }
                else if hasAnswered && isSelected && !isCorrect { Image(systemName: "xmark.circle.fill").font(.system(size: 22)).foregroundColor(AppColors.danger) }
            }.padding(.horizontal, 16).padding(.vertical, 18).background(RoundedRectangle(cornerRadius: 16).fill(bgColor).stroke(borderColor, lineWidth: (isSelected || (hasAnswered && isCorrect)) ? 2 : 1))
        }.buttonStyle(.plain).disabled(hasAnswered).animation(.easeInOut(duration: 0.3), value: viewModel.selectedAnswerIndex)
    }

    private var resultsView: some View {
        let pct = viewModel.totalQuestions > 0 ? (viewModel.score * 100) / viewModel.totalQuestions : 0
        let color: Color = pct >= 80 ? AppColors.success : pct >= 50 ? AppColors.warning : AppColors.danger
        let msg = pct >= 80 ? "Excellent! You're a master! 🏆" : pct >= 50 ? "Good effort! Keep learning! 📚" : "Don't give up! Try again! 💪"

        return VStack(spacing: 20) {
            Spacer().frame(height: 32)
            ZStack { Circle().fill(RadialGradient(colors: [color.opacity(0.2), color.opacity(0.05)], center: .center, startRadius: 0, endRadius: 50)).frame(width: 100, height: 100); Image(systemName: "trophy.fill").font(.system(size: 48)).foregroundColor(color) }
            Text("Quiz Complete!").font(.system(size: 32, weight: .black)).foregroundColor(.appPrimary)
            Text(msg).font(.system(size: 16)).foregroundColor(.appOnSurfaceVariant).multilineTextAlignment(.center).padding(.horizontal, 24)
            VStack(spacing: 8) {
                Text("Your Score").font(.system(size: 20)).foregroundColor(.appOnSurfaceVariant)
                Text("\(viewModel.score) / \(viewModel.totalQuestions)").font(.system(size: 57, weight: .black)).foregroundColor(color)
                Text("\(pct)%").font(.system(size: 28, weight: .semibold)).foregroundColor(.appOnSurfaceVariant)
            }.padding(40).frame(maxWidth: .infinity).background(RoundedRectangle(cornerRadius: 24).fill(LinearGradient(colors: [AppColors.quizGradientStart.opacity(0.15), AppColors.quizGradientEnd.opacity(0.05)], startPoint: .top, endPoint: .bottom))).padding(.horizontal, 24)
            Spacer().frame(height: 24)
            Button(action: onBack) { Text("Return to Quizzes").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 56).background(AppColors.quizGradientStart).clipShape(RoundedRectangle(cornerRadius: 16)) }.padding(.horizontal, 24)
            Spacer().frame(height: 32)
        }
    }
}
