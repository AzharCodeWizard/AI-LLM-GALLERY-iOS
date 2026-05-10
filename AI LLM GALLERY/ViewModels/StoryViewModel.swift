//
//  StoryViewModel.swift
//  AI LLM GALLERY
//

import SwiftUI
import Combine
import SwiftData

@MainActor
final class StoryViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var isGenerating = false
    @Published var currentStory: Story? = nil
    @Published var error: String? = nil
    @Published var isGeneratingAudio = false

    private let llmManager = LlmInferenceManager.shared
    let ttsManager = TtsManager()
    private var modelContext: ModelContext?

    static let genres = ["Fantasy", "Sci-Fi", "Mystery", "Romance", "Horror", "Adventure", "Comedy", "Song Lyrics", "Poem"]
    private static let ttsMaxChars = 500

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        fetchStories()
    }

    func fetchStories() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<Story>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        stories = (try? context.fetch(descriptor)) ?? []
    }

    func generateStory(promptTopic: String, genre: String = "Fantasy") {
        guard let context = modelContext else { return }

        isGenerating = true
        error = nil

        let isSongOrPoem = ["Song Lyrics", "Poem"].contains(genre)

        let systemPrompt: String
        if isSongOrPoem {
            systemPrompt = """
            You are a world-renowned songwriter and poet.
            Your task is to write a \(genre) based on the user's prompt.
            
            Guidelines:
            - Format: Use verses, chorus (for songs), and stanzas (for poems). Label them clearly.
            - Style: Emotionally resonant, rhythmic, and memorable.
            - Length: 3-4 verses with a chorus for songs, or 3-5 stanzas for poems.
            - Constraints: Do not include any introductions, meta-commentary, or explanations. Output ONLY the lyrics/poem text itself. Always respond in English only.
            """
        } else {
            systemPrompt = """
            You are a world-renowned, award-winning author known for your captivating and immersive storytelling.
            Your task is to write a short, engaging story based on the user's prompt.
            
            Guidelines:
            - Genre: \(genre)
            - Length: Approximately 3 to 5 well-developed paragraphs.
            - Style: Highly descriptive, emotionally resonant, and engaging from the very first sentence.
            - Constraints: Do not include any introductions, conclusions, meta-commentary, or titles. Output ONLY the story text itself. Always respond in English only.
            """
        }

        let contentType = isSongOrPoem ? genre.lowercased() : "story"
        let prompt = """
        <|im_start|>system
        \(systemPrompt)
        <|im_end|>
        <|im_start|>user
        Write a compelling \(contentType) about: \(promptTopic).
        <|im_end|>
        <|im_start|>assistant
        """

        Task {
            do {
                let response = await llmManager.generateCompleteResponse(prompt: prompt)

                // Clean the response
                var cleanResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\\n", with: "\n")

                // Remove leading meta-text
                if let range = cleanResponse.range(of: "Song Lyrics:\\s*\\n*", options: [.regularExpression, .caseInsensitive]) {
                    cleanResponse.removeSubrange(range)
                }
                if let range = cleanResponse.range(of: "Poem:\\s*\\n*", options: [.regularExpression, .caseInsensitive]) {
                    cleanResponse.removeSubrange(range)
                }
                cleanResponse = cleanResponse.trimmingCharacters(in: .whitespacesAndNewlines)

                // Determine title
                let titleWords = promptTopic.split(separator: " ").prefix(4).joined(separator: " ")
                let prefix: String
                switch genre {
                case "Song Lyrics": prefix = "Song:"
                case "Poem": prefix = "Poem:"
                default: prefix = "The Tale of"
                }
                let title = "\(prefix) \(titleWords)".prefix(1).uppercased() + String("\(prefix) \(titleWords)".dropFirst())

                let story = Story(title: title, content: cleanResponse, genre: genre)
                context.insert(story)
                try context.save()

                currentStory = story
                fetchStories()

            } catch {
                self.error = "Failed to generate: Ensure a model is loaded and try again."
                print("[Story] Generation failed: \(error)")
            }

            isGenerating = false
        }
    }

    func loadStory(_ story: Story) {
        currentStory = story
    }

    func clearCurrentStory() {
        ttsManager.stop()
        currentStory = nil
    }

    func playStory() {
        guard let fullText = currentStory?.content, !fullText.isEmpty else { return }

        // Truncate for TTS performance
        let text: String
        if fullText.count > Self.ttsMaxChars {
            let truncated = String(fullText.prefix(Self.ttsMaxChars))
            if let lastPeriod = truncated.lastIndex(of: "."),
               truncated.distance(from: truncated.startIndex, to: lastPeriod) > Self.ttsMaxChars / 2 {
                text = String(truncated[...lastPeriod])
            } else {
                text = truncated + "..."
            }
        } else {
            text = fullText
        }

        isGeneratingAudio = true
        ttsManager.speak(text)
        isGeneratingAudio = false
    }

    func stopStory() {
        ttsManager.stop()
    }

    func deleteStory(_ story: Story) {
        guard let context = modelContext else { return }
        if currentStory === story {
            stopStory()
            currentStory = nil
        }
        context.delete(story)
        try? context.save()
        fetchStories()
    }
}
