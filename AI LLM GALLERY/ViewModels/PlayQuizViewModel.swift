//
//  PlayQuizViewModel.swift
//  AI LLM GALLERY
//

import SwiftUI
import Combine
import SwiftData

@MainActor
final class PlayQuizViewModel: ObservableObject {
    @Published var quiz: Quiz? = nil
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var isFinished = false
    @Published var selectedAnswerIndex: Int? = nil

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func loadQuiz(quizId: String) {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Quiz>()
        let allQuizzes = (try? context.fetch(descriptor)) ?? []

        // Find quiz by persistent model ID string
        quiz = allQuizzes.first { $0.persistentModelID.hashValue.description == quizId }

        currentQuestionIndex = 0
        score = 0
        isFinished = false
        selectedAnswerIndex = nil
    }

    var currentQuestion: Question? {
        guard let questions = quiz?.questions,
              currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var totalQuestions: Int {
        quiz?.questions.count ?? 0
    }

    var progress: Float {
        guard totalQuestions > 0 else { return 0 }
        return Float(currentQuestionIndex + 1) / Float(totalQuestions)
    }

    func submitAnswer(_ index: Int) {
        guard selectedAnswerIndex == nil else { return } // Already answered

        selectedAnswerIndex = index
        if let question = currentQuestion, index == question.correctAnswerIndex {
            score += 1
        }
    }

    func nextQuestion() {
        if currentQuestionIndex + 1 < totalQuestions {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
        } else {
            isFinished = true
        }
    }
}
