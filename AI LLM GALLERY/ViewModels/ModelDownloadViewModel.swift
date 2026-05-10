//
//  ModelDownloadViewModel.swift
//  AI LLM GALLERY
//

import SwiftUI
import Combine

@MainActor
final class ModelDownloadViewModel: ObservableObject {
    @Published var downloadedModelIds: Set<String> = []
    @Published var downloadStates: [String: DownloadState] = [:]

    let downloadManager = ModelDownloadManager()
    let models: [DownloadableModel] = ModelCatalog.models

    private var cancellables = Set<AnyCancellable>()

    init() {
        refreshDownloadedModels()

        // Subscribe to download state changes via Combine
        downloadManager.statePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] (modelId, state) in
                guard let self else { return }
                self.downloadStates[modelId] = state

                // Auto-refresh downloaded list on completion
                if case .completed = state {
                    self.refreshDownloadedModels()
                }
            }
            .store(in: &cancellables)
    }

    func refreshDownloadedModels() {
        downloadedModelIds = downloadManager.getDownloadedModelIds()
    }

    func downloadModel(_ model: DownloadableModel) {
        downloadManager.downloadModel(model)
    }

    func cancelDownload(_ modelId: String) {
        downloadManager.cancelDownload(modelId)
    }

    func deleteModel(_ model: DownloadableModel) {
        downloadManager.deleteModel(model)
        refreshDownloadedModels()
    }
}
