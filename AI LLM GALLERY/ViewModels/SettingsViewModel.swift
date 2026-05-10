import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var downloadedModels: [URL] = []

    private let llmManager = LlmInferenceManager.shared

    @Published var activeModelName: String = "No model loaded"

    private var cancellables = Set<AnyCancellable>()

    init() {
        refreshModels()
        
        llmManager.$activeModelName
            .receive(on: RunLoop.main)
            .sink { [weak self] name in
                self?.activeModelName = name
            }
            .store(in: &cancellables)
    }

    func refreshModels() {
        downloadedModels = llmManager.getDownloadedModels()
    }

    @Published var initializationError: String? = nil

    func selectModel(_ fileURL: URL) {
        Task {
            initializationError = nil
            await llmManager.initialize(modelPath: fileURL.path)
            
            if case .error(let message) = llmManager.modelState {
                print("Model Init Error: \(message)")
                self.initializationError = message
            }
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
}
