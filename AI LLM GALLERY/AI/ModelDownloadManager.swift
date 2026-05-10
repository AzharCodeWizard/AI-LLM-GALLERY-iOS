//
//  ModelDownloadManager.swift
//  AI LLM GALLERY
//
//  Handles model downloads via URLSession with real-time progress tracking.
//

import Foundation
import Combine

// MARK: - Model Download Manager

final class ModelDownloadManager: NSObject, URLSessionDownloadDelegate {
    /// Publishes (modelId, state) updates that the ViewModel subscribes to via Combine
    let statePublisher = PassthroughSubject<(String, DownloadState), Never>()

    private var activeTasks: [String: URLSessionDownloadTask] = [:]
    private var modelMapping: [Int: String] = [:] // taskIdentifier -> modelId
    private var modelFileNames: [String: String] = [:] // modelId -> fileName

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }()

    private let fileManager = FileManager.default

    var modelsDirectory: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("models")
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    // MARK: - Download Operations

    func downloadModel(_ model: DownloadableModel) {
        guard activeTasks[model.id] == nil else { return }
        guard let url = URL(string: model.downloadUrl) else {
            statePublisher.send((model.id, .failed(error: "Invalid URL")))
            return
        }

        let task = session.downloadTask(with: url)
        activeTasks[model.id] = task
        modelMapping[task.taskIdentifier] = model.id
        modelFileNames[model.id] = model.fileName

        statePublisher.send((model.id, .downloading(progress: 0, downloadedBytes: 0, totalBytes: model.sizeBytes)))
        task.resume()
        print("[Download] Started: \(model.name)")
    }

    func cancelDownload(_ modelId: String) {
        activeTasks[modelId]?.cancel()
        activeTasks.removeValue(forKey: modelId)
        statePublisher.send((modelId, .idle))
        print("[Download] Cancelled: \(modelId)")
    }

    func deleteModel(_ model: DownloadableModel) {
        let fileURL = modelsDirectory.appendingPathComponent(model.fileName)
        try? fileManager.removeItem(at: fileURL)
        statePublisher.send((model.id, .idle))
        print("[Download] Deleted: \(model.name)")
    }

    func getDownloadedModelIds() -> Set<String> {
        guard let files = try? fileManager.contentsOfDirectory(
            at: modelsDirectory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ) else { return [] }

        let downloadedFileNames = Set(files.map { $0.lastPathComponent })
        var ids = Set<String>()

        for model in ModelCatalog.models {
            if downloadedFileNames.contains(model.fileName) {
                ids.insert(model.id)
            }
        }
        return ids
    }

    // MARK: - URLSession Download Delegate

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let modelId = modelMapping[downloadTask.taskIdentifier] else { return }

        let total = totalBytesExpectedToWrite > 0 ? totalBytesExpectedToWrite : 1
        let progress = Float(totalBytesWritten) / Float(total)

        statePublisher.send((modelId, .downloading(
            progress: progress,
            downloadedBytes: totalBytesWritten,
            totalBytes: totalBytesExpectedToWrite
        )))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let modelId = modelMapping[downloadTask.taskIdentifier],
              let fileName = modelFileNames[modelId] else { return }

        // Check for HTTP errors (e.g. 404 Not Found or 401 Unauthorized)
        if let httpResponse = downloadTask.response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            
            activeTasks.removeValue(forKey: modelId)
            statePublisher.send((modelId, .failed(error: "HTTP Error \(httpResponse.statusCode)")))
            print("[Download] Failed with HTTP \(httpResponse.statusCode) for \(fileName)")
            return
        }

        let destinationURL = modelsDirectory.appendingPathComponent(fileName)

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: location, to: destinationURL)

            activeTasks.removeValue(forKey: modelId)
            statePublisher.send((modelId, .completed))
            print("[Download] Complete: \(fileName)")
        } catch {
            activeTasks.removeValue(forKey: modelId)
            statePublisher.send((modelId, .failed(error: error.localizedDescription)))
            print("[Download] Failed to save: \(error)")
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error,
              let modelId = modelMapping[task.taskIdentifier] else { return }

        if (error as NSError).code == NSURLErrorCancelled { return }

        activeTasks.removeValue(forKey: modelId)
        statePublisher.send((modelId, .failed(error: error.localizedDescription)))
        print("[Download] Error for \(modelId): \(error)")
    }
}
