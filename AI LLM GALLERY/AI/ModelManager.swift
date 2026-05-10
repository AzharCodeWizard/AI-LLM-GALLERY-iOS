//
//  ModelManager.swift
//  AI LLM GALLERY
//
//  Scans for downloaded model files in the app's Documents/models directory.
//

import Foundation
import Combine

// MARK: - Model Info

struct ModelInfo: Identifiable, Equatable {
    let id: String
    let name: String
    let path: String
    let sizeBytes: Int64
    let fileName: String

    var sizeDisplay: String {
        ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file)
    }

    static func == (lhs: ModelInfo, rhs: ModelInfo) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Model Manager

@MainActor
final class ModelManager: ObservableObject {
    @Published var modelState: ModelState = .idle
    @Published var availableModels: [ModelInfo] = []

    private let fileManager = FileManager.default

    var modelsDirectory: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("models")
    }

    func ensureModelsDirectory() {
        if !fileManager.fileExists(atPath: modelsDirectory.path) {
            try? fileManager.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
        }
    }

    func scanForModels() {
        modelState = .scanning

        ensureModelsDirectory()

        guard let files = try? fileManager.contentsOfDirectory(
            at: modelsDirectory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: .skipsHiddenFiles
        ) else {
            modelState = .notFound
            return
        }

        let modelFiles = files.filter { url in
            let ext = url.pathExtension.lowercased()
            return ext == "task" || ext == "bin"
        }

        if modelFiles.isEmpty {
            modelState = .notFound
            availableModels = []
            return
        }

        availableModels = modelFiles.compactMap { url in
            let resources = try? url.resourceValues(forKeys: [.fileSizeKey])
            let size = Int64(resources?.fileSize ?? 0)
            let name = url.deletingPathExtension().lastPathComponent

            return ModelInfo(
                id: url.lastPathComponent,
                name: name,
                path: url.path,
                sizeBytes: size,
                fileName: url.lastPathComponent
            )
        }.sorted { $0.name < $1.name }

        // Auto-select the first model
        if let firstModel = availableModels.first {
            modelState = .ready(path: firstModel.path)
        }
    }
}
