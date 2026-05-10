import UIKit
import Vision

struct VisionAnalysisResult {
    var labels: [String] = []
    var detectedText: [String] = []
    var faceCount: Int = 0
    var animalLabels: [String] = []
    var isSalient: Bool = false

    var summary: String {
        var parts: [String] = []

        if !labels.isEmpty {
            parts.append("Detected objects/scenes: \(labels.joined(separator: ", "))")
        }

        if faceCount > 0 {
            parts.append("Number of human faces detected: \(faceCount)")
        } else {
            parts.append("No human faces detected in the image")
        }

        if !animalLabels.isEmpty {
            parts.append("Animals detected: \(animalLabels.joined(separator: ", "))")
        }

        if !detectedText.isEmpty {
            parts.append("Text found in image: \"\(detectedText.joined(separator: " "))\"")
        }

        if parts.isEmpty {
            return "The image could not be analyzed in detail."
        }

        return parts.joined(separator: ". ") + "."
    }
}

final class VisionAnalyzer {

    static func analyze(image: UIImage) async -> VisionAnalysisResult {
        guard let cgImage = image.cgImage else {
            return VisionAnalysisResult()
        }

        let orientation = cgImageOrientation(from: image.imageOrientation)

        async let classificationResult = runClassification(cgImage: cgImage, orientation: orientation)
        async let textResult = runTextRecognition(cgImage: cgImage, orientation: orientation)
        async let faceResult = runFaceDetection(cgImage: cgImage, orientation: orientation)
        async let animalResult = runAnimalRecognition(cgImage: cgImage, orientation: orientation)

        let (labels, text, faces, animals) = await (classificationResult, textResult, faceResult, animalResult)

        return VisionAnalysisResult(
            labels: labels,
            detectedText: text,
            faceCount: faces,
            animalLabels: animals
        )
    }

    private static func runClassification(cgImage: CGImage, orientation: CGImagePropertyOrientation) async -> [String] {
        await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                guard let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                let topLabels = results
                    .filter { $0.confidence > 0.3 }
                    .prefix(8)
                    .map { "\($0.identifier.replacingOccurrences(of: "_", with: " ")) (\(Int($0.confidence * 100))%)" }
                continuation.resume(returning: Array(topLabels))
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: [])
            }
        }
    }

    private static func runTextRecognition(cgImage: CGImage, orientation: CGImagePropertyOrientation) async -> [String] {
        await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard let results = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                let texts = results.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: texts)
            }
            request.recognitionLevel = .accurate

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: [])
            }
        }
    }

    private static func runFaceDetection(cgImage: CGImage, orientation: CGImagePropertyOrientation) async -> Int {
        await withCheckedContinuation { continuation in
            let request = VNDetectFaceRectanglesRequest { request, error in
                let count = (request.results as? [VNFaceObservation])?.count ?? 0
                continuation.resume(returning: count)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: 0)
            }
        }
    }

    private static func runAnimalRecognition(cgImage: CGImage, orientation: CGImagePropertyOrientation) async -> [String] {
        await withCheckedContinuation { continuation in
            let request = VNRecognizeAnimalsRequest { request, error in
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                let animals = results.flatMap { $0.labels.map { $0.identifier } }
                continuation.resume(returning: animals)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: [])
            }
        }
    }

    private static func cgImageOrientation(from uiOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch uiOrientation {
        case .up:            return .up
        case .down:          return .down
        case .left:          return .left
        case .right:         return .right
        case .upMirrored:    return .upMirrored
        case .downMirrored:  return .downMirrored
        case .leftMirrored:  return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default:    return .up
        }
    }
}
