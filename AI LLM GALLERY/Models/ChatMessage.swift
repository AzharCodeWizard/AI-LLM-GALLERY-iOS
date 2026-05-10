//
//  ChatMessage.swift
//  AI LLM GALLERY
//

import SwiftUI
import UIKit

// MARK: - Chat Message

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    var text: String
    let isUser: Bool
    let timestamp: Date
    var image: UIImage?
    var inferenceTimeMs: Int64?
    var isStreaming: Bool

    init(
        id: UUID = UUID(),
        text: String,
        isUser: Bool,
        timestamp: Date = Date(),
        image: UIImage? = nil,
        inferenceTimeMs: Int64? = nil,
        isStreaming: Bool = false
    ) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
        self.image = image
        self.inferenceTimeMs = inferenceTimeMs
        self.isStreaming = isStreaming
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id && lhs.text == rhs.text && lhs.isStreaming == rhs.isStreaming
    }
}
