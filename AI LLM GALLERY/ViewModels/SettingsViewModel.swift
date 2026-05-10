//
//  SettingsViewModel.swift
//  AI LLM GALLERY
//

import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var downloadedModels: [URL] = []

    private let llmManager = LlmInferenceManager.shared

    var activeModelName: String {
        llmManager.activeModelName
    }

    init() {
        refreshModels()
    }

    func refreshModels() {
        downloadedModels = llmManager.getDownloadedModels()
    }

    func selectModel(_ fileURL: URL) {
        Task {
            await llmManager.initialize(modelPath: fileURL.path)
        }
    }

    func deleteModel(_ fileURL: URL) {
        if llmManager.deleteModel(fileName: fileURL.lastPathComponent) {
            refreshModels()
        }
    }

    func clearAllModels() {
        for model in downloadedModels {
            _ = llmManager.deleteModel(fileName: model.lastPathComponent)
        }
        refreshModels()
    }

    func activateDemoMode() {
        llmManager.initializeMock("Demo Engine (Manual)")
    }
}
