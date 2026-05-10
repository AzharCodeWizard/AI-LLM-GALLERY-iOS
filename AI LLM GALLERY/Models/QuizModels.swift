//
//  QuizModels.swift
//  AI LLM GALLERY
//

import Foundation
import SwiftData

// MARK: - Quiz Model

@Model
final class Quiz {
    var title: String
    var topic: String
    var timestamp: Date

    @Relationship(deleteRule: .cascade, inverse: \Question.quiz)
    var questions: [Question]

    init(title: String, topic: String, timestamp: Date = Date()) {
        self.title = title
        self.topic = topic
        self.timestamp = timestamp
        self.questions = []
    }
}

// MARK: - Question Model

@Model
final class Question {
    var questionText: String
    var options: [String]
    var correctAnswerIndex: Int
    var explanation: String?
    var quiz: Quiz?

    init(
        questionText: String,
        options: [String],
        correctAnswerIndex: Int,
        explanation: String? = nil,
        quiz: Quiz? = nil
    ) {
        self.questionText = questionText
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.quiz = quiz
    }
}
