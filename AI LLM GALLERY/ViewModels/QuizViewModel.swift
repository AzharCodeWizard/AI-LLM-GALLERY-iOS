import SwiftUI
import Combine
import SwiftData

@MainActor
final class QuizViewModel: ObservableObject {
    @Published var quizzes: [Quiz] = []
    @Published var isGenerating = false
    @Published var error: String? = nil

    private let llmManager = LlmInferenceManager.shared
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        fetchQuizzes()
    }

    func fetchQuizzes() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<Quiz>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        quizzes = (try? context.fetch(descriptor)) ?? []
    }

    func generateQuiz(topic: String) {
        guard let context = modelContext else { return }

        isGenerating = true
        error = nil

        let prompt = """
        <|im_start|>system
        You are an expert educational AI. Generate a 5-question multiple-choice quiz about the user's topic.
        OUTPUT ONLY VALID JSON. NO MARKDOWN. NO TEXT OUTSIDE JSON.
        
        {
          "title": "Quiz Title",
          "questions": [
            {
              "text": "Question?",
              "options": ["A", "B", "C", "D"],
              "correct": 0
            }
          ]
        }
        <|im_end|>
        <|im_start|>user
        Generate a quiz about: \(topic).
        <|im_end|>
        <|im_start|>assistant
        """

        Task {
            do {
                let responseJson = await llmManager.generateCompleteResponse(prompt: prompt)

                if responseJson.isEmpty {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "The model returned an empty response."])
                }

                let cleanJson = responseJson
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .replacingOccurrences(of: "<|im_end|>", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                guard let jsonString = Self.extractJSON(from: cleanJson) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find a valid JSON object { ... } in the response."])
                }

                guard let data = jsonString.data(using: .utf8) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON as UTF-8."])
                }

                var jsonObject: [String: Any]?
                jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]

                if jsonObject == nil {
                    let repairedString = Self.repairJSON(jsonString)
                    if let repairedData = repairedString.data(using: .utf8) {
                        jsonObject = try? JSONSerialization.jsonObject(with: repairedData) as? [String: Any]
                    }
                }

                guard let parsed = jsonObject else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "The JSON was malformed and could not be repaired."])
                }

                let title = parsed["title"] as? String ?? parsed["name"] as? String ?? "\(topic) Quiz"
                
                let questionsArray = (parsed["questions"] as? [[String: Any]]) 
                    ?? (parsed["quiz"] as? [[String: Any]]) 
                    ?? (parsed["data"] as? [[String: Any]])

                guard let array = questionsArray, !array.isEmpty else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "The response did not contain a list of questions."])
                }

                let quiz = Quiz(title: title, topic: topic)
                context.insert(quiz)

                var validCount = 0
                for qObj in array {
                    guard let text = qObj["text"] as? String 
                            ?? qObj["question"] as? String 
                            ?? qObj["q"] as? String,
                          let options = qObj["options"] as? [String],
                          options.count >= 2 else { continue }

                    var correctIdx = 0
                    if let c = qObj["correct"] as? Int {
                        correctIdx = c
                    } else if let c = qObj["correct_index"] as? Int {
                        correctIdx = c
                    } else if let c = qObj["answer_index"] as? Int {
                        correctIdx = c
                    } else if let c = qObj["correct"] as? String, let ci = Int(c) {
                        correctIdx = ci
                    } else if let answerStr = qObj["answer"] as? String {
                        correctIdx = options.firstIndex(of: answerStr) ?? 0
                    }

                    correctIdx = max(0, min(correctIdx, options.count - 1))

                    let question = Question(
                        questionText: text,
                        options: options,
                        correctAnswerIndex: correctIdx,
                        quiz: quiz
                    )
                    context.insert(question)
                    validCount += 1
                }

                if validCount == 0 {
                    context.delete(quiz)
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No valid questions were found in the response."])
                }

                try context.save()
                fetchQuizzes()

            } catch {
                self.error = "Generation failed: \(error.localizedDescription)"
            }

            isGenerating = false
        }
    }

    func deleteQuiz(_ quiz: Quiz) {
        guard let context = modelContext else { return }
        context.delete(quiz)
        try? context.save()
        fetchQuizzes()
    }

    private static func extractJSON(from text: String) -> String? {
        guard let startIdx = text.firstIndex(of: "{") else { return nil }

        var depth = 0
        var endIdx = startIdx

        for idx in text[startIdx...].indices {
            let char = text[idx]
            if char == "{" { depth += 1 }
            if char == "}" {
                depth -= 1
                if depth == 0 {
                    endIdx = idx
                    break
                }
            }
        }

        guard depth == 0 else {
            let partial = String(text[startIdx...])
            let missing = partial.filter { $0 == "{" }.count - partial.filter { $0 == "}" }.count
            if missing > 0 && missing <= 3 {
                return partial + String(repeating: "}", count: missing)
            }
            return nil
        }

        return String(text[startIdx...endIdx])
    }

    private static func repairJSON(_ json: String) -> String {
        var fixed = json

        fixed = fixed.replacingOccurrences(
            of: ",\\s*([\\]\\}])",
            with: "$1",
            options: .regularExpression
        )

        if !fixed.contains("\"") && fixed.contains("'") {
            fixed = fixed.replacingOccurrences(of: "'", with: "\"")
        }

        fixed = fixed.replacingOccurrences(
            of: "([{,]\\s*)(\\w+)(\\s*:)",
            with: "$1\"$2\"$3",
            options: .regularExpression
        )

        let trimmed = fixed.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.hasSuffix("}") {
            let openBraces = trimmed.filter { $0 == "{" }.count
            let closeBraces = trimmed.filter { $0 == "}" }.count
            if openBraces > closeBraces {
                fixed = trimmed + String(repeating: "}", count: openBraces - closeBraces)
            }
        }

        return fixed
    }
}
