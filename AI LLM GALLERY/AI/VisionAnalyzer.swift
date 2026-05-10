import UIKit
import Vision

struct VisionAnalysisResult {
    var labels: [String] = []
    var detectedText: [String] = []
    var faceCount: Int = 0
    var animalLabels: [String] = []

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

        return await Task.detached {
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])

            let classifyRequest = VNClassifyImageRequest()
            let textRequest = VNRecognizeTextRequest()
            textRequest.recognitionLevel = .accurate
            let faceRequest = VNDetectFaceRectanglesRequest()
            let animalRequest = VNRecognizeAnimalsRequest()

            do {
                try handler.perform([classifyRequest, textRequest, faceRequest, animalRequest])
            } catch {
                return VisionAnalysisResult()
            }

            let labels: [String] = (classifyRequest.results as? [VNClassificationObservation] ?? [])
                .filter { $0.confidence > 0.3 }
                .prefix(8)
                .map { "\($0.identifier.replacingOccurrences(of: "_", with: " ")) (\(Int($0.confidence * 100))%)" }

            let detectedText: [String] = (textRequest.results as? [VNRecognizedTextObservation] ?? [])
                .compactMap { $0.topCandidates(1).first?.string }

            let faceCount = (faceRequest.results as? [VNFaceObservation])?.count ?? 0

            let animalLabels: [String] = (animalRequest.results as? [VNRecognizedObjectObservation] ?? [])
                .flatMap { $0.labels.map { $0.identifier } }

            return VisionAnalysisResult(
                labels: Array(labels),
                detectedText: detectedText,
                faceCount: faceCount,
                animalLabels: animalLabels
            )
        }.value
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
