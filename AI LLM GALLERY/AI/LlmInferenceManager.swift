import Foundation
import Combine

#if canImport(UIKit)
import UIKit
#endif

#if canImport(MediaPipeTasksGenAI)
import MediaPipeTasksGenAI
#endif

enum ModelState: Equatable {
    case idle
    case scanning
    case ready(path: String)
    case notFound
    case error(message: String)
}

@MainActor
final class LlmInferenceManager: ObservableObject {
    static let shared = LlmInferenceManager()

    @Published var isInitialized = false
    @Published var activeModelName = "No model loaded"
    @Published var modelState: ModelState = .idle

    private var isGenerating = false
    private var relativeModelPath: String?

    #if canImport(MediaPipeTasksGenAI)
    private var llmInference: LlmInference?
    #endif

    private init() {}

    func initialize(modelPath: String) async {
        await waitForGeneration()

        if !FileManager.default.fileExists(atPath: modelPath) {
            modelState = .error(message: "Model file not found")
            return
        }

        if !ModelFileValidator.isValidTaskFile(atPath: modelPath) {
            modelState = .error(message: "Model file is corrupted or invalid. Please delete and re-download.")
            try? FileManager.default.removeItem(atPath: modelPath)
            return
        }

        let fileName = (modelPath as NSString).lastPathComponent
        let displayName = fileName
            .replacingOccurrences(of: ".task", with: "")
            .replacingOccurrences(of: ".bin", with: "")

        self.relativeModelPath = fileName

        #if canImport(MediaPipeTasksGenAI)
        do {
            let options = LlmInference.Options(modelPath: modelPath)
            options.maxTokens = 2048
            options.maxTopk = 40

            self.llmInference = try LlmInference(options: options)

            activeModelName = displayName
            isInitialized = true
            modelState = .ready(path: modelPath)
            return
        } catch {
            modelState = .error(message: "Initialization failed: \(error.localizedDescription)")
        }
        #endif
    }

    private func waitForGeneration() async {
        var waitCount = 0
        while isGenerating {
            try? await Task.sleep(nanoseconds: 200_000_000)
            waitCount += 1
            if waitCount > 50 {
                isGenerating = false
                break
            }
        }
    }

    private func ensureModelReady() async -> Bool {
        #if canImport(MediaPipeTasksGenAI)
        guard isInitialized else { return false }
        
        guard let relative = relativeModelPath else { return false }
        
        let currentPath = getModelsDirectory().appendingPathComponent(relative).path
        
        if !FileManager.default.fileExists(atPath: currentPath) { return false }
        
        if llmInference == nil {
            await initialize(modelPath: currentPath)
        }
        
        return llmInference != nil
        #else
        return false
        #endif
    }

    func generateStreamingResponse(prompt: String) -> AsyncStream<String> {
        #if canImport(MediaPipeTasksGenAI)
        return AsyncStream { continuation in
            Task { @MainActor in
                guard await self.ensureModelReady() else {
                    continuation.finish()
                    return
                }

                if let inference = self.llmInference {
                    await self.waitForGeneration()
                    self.isGenerating = true
                    
                    Task.detached { [weak self] in
                        do {
                            let session = try LlmInference.Session(llmInference: inference)
                            try session.addQueryChunk(inputText: prompt)
                            let stream = session.generateResponseAsync()
                            for try await chunk in stream {
                                continuation.yield(chunk)
                            }
                        } catch {
                        }

                        await MainActor.run { self?.isGenerating = false }
                        continuation.finish()
                    }
                } else {
                    continuation.finish()
                }
            }
        }
        #else
        return AsyncStream { $0.finish() }
        #endif
    }

    func generateCompleteResponse(prompt: String) async -> String {
        #if canImport(MediaPipeTasksGenAI)
        guard await ensureModelReady() else {
            return ""
        }

        if let inference = llmInference {
            await waitForGeneration()
            isGenerating = true
            
            let result: String = await Task.detached { [weak self] in
                do {
                    let session = try LlmInference.Session(llmInference: inference)
                    try session.addQueryChunk(inputText: prompt)
                    return try session.generateResponse()
                } catch {
                    return ""
                }
            }.value

            isGenerating = false
            return result
        }
        #endif
        return ""
    }

    func getDownloadedModels() -> [URL] {
        let modelsDir = getModelsDirectory()
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: modelsDir,
            includingPropertiesForKeys: [.fileSizeKey],
            options: .skipsHiddenFiles
        ) else { return [] }

        return files.filter { url in
            let ext = url.pathExtension.lowercased()
            return ext == "task" || ext == "bin"
        }.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    func deleteModel(fileName: String) -> Bool {
        let fileURL = getModelsDirectory().appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
            if activeModelName.contains(fileName.replacingOccurrences(of: ".task", with: "")) {
                activeModelName = "No model loaded"
                isInitialized = false
                modelState = .notFound
            }
            return true
        } catch {
            return false
        }
    }

    func getModelsDirectory() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let modelsDir = docs.appendingPathComponent("models")
        if !FileManager.default.fileExists(atPath: modelsDir.path) {
            try? FileManager.default.createDirectory(at: modelsDir, withIntermediateDirectories: true, attributes: nil)
        }
        return modelsDir
    }

}

enum ModelFileValidator {
    static func isValidTaskFile(atPath path: String) -> Bool {
        guard let fileHandle = FileHandle(forReadingAtPath: path) else { return false }
        defer { fileHandle.closeFile() }

        let header = fileHandle.readData(ofLength: 4)
        guard header.count >= 4 else { return false }

        let zipMagic: [UInt8] = [0x50, 0x4B, 0x03, 0x04]
        let fileBytes = [UInt8](header)
        return fileBytes[0] == zipMagic[0]
            && fileBytes[1] == zipMagic[1]
            && fileBytes[2] == zipMagic[2]
            && fileBytes[3] == zipMagic[3]
    }
}
