import SwiftUI
import Combine
import UIKit

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var selectedImage: UIImage? = nil

    private let llmManager = LlmInferenceManager.shared
    private let capability: AiCapability

    var modelStatusText: String {
        llmManager.isInitialized ? llmManager.activeModelName : "No model loaded"
    }

    var isModelReady: Bool {
        llmManager.isInitialized
    }

    var requiresImageInput: Bool {
        capability.requiresImageInput
    }

    init(capabilityId: String) {
        self.capability = AiCapabilities.all.first { $0.id == capabilityId }
            ?? AiCapabilities.all[0]
    }

    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !isLoading else { return }

        let userMessage = ChatMessage(
            text: text,
            isUser: true,
            image: selectedImage
        )
        messages.append(userMessage)
        selectedImage = nil

        let aiMessageId = UUID()
        let aiMessage = ChatMessage(
            id: aiMessageId,
            text: "",
            isUser: false,
            isStreaming: true
        )
        messages.append(aiMessage)
        isLoading = true

        let prompt = buildPrompt(userText: text)

        Task {
            let startTime = Date()
            var fullResponse = ""

            let stream = llmManager.generateStreamingResponse(prompt: prompt)

            for await chunk in stream {
                fullResponse += chunk
                if let index = messages.firstIndex(where: { $0.id == aiMessageId }) {
                    messages[index].text = Self.cleanResponse(fullResponse)
                }
            }

            let inferenceTime = Int64(Date().timeIntervalSince(startTime) * 1000)

            if let index = messages.firstIndex(where: { $0.id == aiMessageId }) {
                messages[index].text = Self.cleanResponse(fullResponse)
                messages[index].isStreaming = false
                messages[index].inferenceTimeMs = inferenceTime
            }

            isLoading = false
        }
    }

    func clearChat() {
        messages.removeAll()
        selectedImage = nil
    }

    private func buildPrompt(userText: String) -> String {
        var prompt = "<|im_start|>system\n\(capability.systemPrompt)\n<|im_end|>\n"

        let historyMessages = Array(messages.dropLast(2).suffix(10))
        for msg in historyMessages {
            let role = msg.isUser ? "user" : "assistant"
            prompt += "<|im_start|>\(role)\n\(msg.text)\n<|im_end|>\n"
        }

        prompt += "<|im_start|>user\n\(userText)\n<|im_end|>\n"
        prompt += "<|im_start|>assistant\n"

        return prompt
    }

    private static func cleanResponse(_ raw: String) -> String {
        var text = raw

        text = text.replacingOccurrences(of: "<|im_end|>", with: "")
        text = text.replacingOccurrences(of: "<|im_start|>", with: "")
        text = text.replacingOccurrences(of: "<|endoftext|>", with: "")

        text = text.replacingOccurrences(of: "\\n", with: "\n")
        text = text.replacingOccurrences(of: "\\t", with: "\t")

        while text.contains("\n\n\n") {
            text = text.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        text = text.trimmingCharacters(in: .whitespacesAndNewlines)

        return text
    }
}
