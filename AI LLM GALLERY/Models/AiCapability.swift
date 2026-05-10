//
//  AiCapability.swift
//  AI LLM GALLERY
//

import SwiftUI

// MARK: - Capability Category

enum CapabilityCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case text = "Text"
    case vision = "Vision"
    case multimodal = "Multimodal"
    case code = "Code"

    var id: String { rawValue }

    var gradientColors: [Color] {
        switch self {
        case .all:        return [AppColors.gradientTextStart, AppColors.gradientTextEnd]
        case .text:       return [AppColors.gradientTextStart, AppColors.gradientTextEnd]
        case .vision:     return [AppColors.gradientVisionStart, AppColors.gradientVisionEnd]
        case .multimodal: return [AppColors.gradientMultimodalStart, AppColors.gradientMultimodalEnd]
        case .code:       return [AppColors.gradientCodeStart, AppColors.gradientCodeEnd]
        }
    }
}

// MARK: - AI Capability

struct AiCapability: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String          // SF Symbol name
    let category: CapabilityCategory
    let requiresImageInput: Bool
    let systemPrompt: String
    let examplePrompts: [String]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AiCapability, rhs: AiCapability) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Capability Registry

enum AiCapabilities {
    static let all: [AiCapability] = [
        AiCapability(
            id: "creative_writing",
            title: "Creative Writing",
            description: "Generate stories, poems, and creative content with AI assistance",
            icon: "pencil.and.outline",
            category: .text,
            requiresImageInput: false,
            systemPrompt: """
            You are a talented creative writer. Help the user with creative writing tasks such as stories, poems, scripts, and other creative content. Be imaginative, expressive, and adapt your style to the user's requests. Always respond in English only.
            """,
            examplePrompts: [
                "Write a short sci-fi story about time travel",
                "Compose a haiku about the ocean",
                "Create a dialogue between two historical figures"
            ]
        ),
        AiCapability(
            id: "summarization",
            title: "Summarization",
            description: "Condense long texts into concise, meaningful summaries",
            icon: "doc.text.magnifyingglass",
            category: .text,
            requiresImageInput: false,
            systemPrompt: """
            You are an expert text summarizer. Your goal is to distill the user's provided text into a clear, concise, and accurate summary. Capture the key ideas and main points. Always respond in English only.
            """,
            examplePrompts: [
                "Summarize the concept of quantum computing in 3 sentences",
                "Give me key points about climate change",
                "Summarize the plot of Romeo and Juliet"
            ]
        ),
        AiCapability(
            id: "code_assistant",
            title: "Code Assistant",
            description: "Get help with coding, debugging, and technical explanations",
            icon: "chevron.left.forwardslash.chevron.right",
            category: .code,
            requiresImageInput: false,
            systemPrompt: """
            You are an expert software engineer and coding assistant. Help the user with code generation, debugging, code review, and technical explanations. Provide clean, well-commented code and clear explanations. Always respond in English only.
            """,
            examplePrompts: [
                "Write a Python function to sort a list",
                "Explain the difference between a stack and a queue",
                "Debug this code: for i in range(10) print(i)"
            ]
        ),
        AiCapability(
            id: "image_captioning",
            title: "Image Captioning",
            description: "Generate detailed descriptions of images using AI vision",
            icon: "text.below.photo",
            category: .vision,
            requiresImageInput: true,
            systemPrompt: """
            You are an advanced image analysis AI. When shown an image, provide a detailed, accurate, and descriptive caption. Describe objects, people, scenes, colors, and notable features. Always respond in English only.
            """,
            examplePrompts: [
                "Describe this image in detail",
                "What objects can you see?",
                "What is happening in this photo?"
            ]
        ),
        AiCapability(
            id: "visual_qa",
            title: "Visual Q&A",
            description: "Ask questions about images and get intelligent answers",
            icon: "questionmark.circle",
            category: .multimodal,
            requiresImageInput: true,
            systemPrompt: """
            You are an intelligent visual question-answering AI. You can analyze images and answer specific questions about their content. Provide accurate and helpful responses. Always respond in English only.
            """,
            examplePrompts: [
                "How many people are in this image?",
                "What color is the car?",
                "Is this indoors or outdoors?"
            ]
        ),
        AiCapability(
            id: "object_detection",
            title: "Object Detection",
            description: "Identify and list objects present in images",
            icon: "viewfinder",
            category: .vision,
            requiresImageInput: true,
            systemPrompt: """
            You are an object detection AI. Analyze images and list all identifiable objects. For each object, provide its name and a brief description of its location in the image. Always respond in English only.
            """,
            examplePrompts: [
                "List all objects in this image",
                "What items are on the table?",
                "Identify the animals in this photo"
            ]
        )
    ]
}
