//
//  StoryModel.swift
//  AI LLM GALLERY
//

import Foundation
import SwiftData

// MARK: - Story Model

@Model
final class Story {
    var title: String
    var content: String
    var genre: String
    var timestamp: Date

    init(
        title: String,
        content: String,
        genre: String,
        timestamp: Date = Date()
    ) {
        self.title = title
        self.content = content
        self.genre = genre
        self.timestamp = timestamp
    }
}
