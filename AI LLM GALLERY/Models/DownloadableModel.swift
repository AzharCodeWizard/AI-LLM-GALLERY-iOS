//
//  DownloadableModel.swift
//  AI LLM GALLERY
//

import Foundation

// MARK: - Model Category

enum ModelCategory: String, CaseIterable {
    case small = "Compact (< 500 MB)"
    case medium = "Standard (500 MB – 1.5 GB)"
    case large = "Performance (1.5 – 3 GB)"
    case extraLarge = "Flagship (3+ GB)"

    var displayName: String { rawValue }
}

// MARK: - Model Family

enum ModelFamily: String {
    case smolLM = "SmolLM"
    case qwen = "Qwen"
    case deepseek = "DeepSeek"
    case gemma = "Gemma"
    case llama = "Llama"
    case phi = "Phi"
    case other = "Other"

    var emoji: String {
        switch self {
        case .smolLM: return "🤗"
        case .qwen: return "🔮"
        case .deepseek: return "🧠"
        case .gemma: return "💎"
        case .llama: return "🦙"
        case .phi: return "Φ"
        case .other: return "🤖"
        }
    }
}

// MARK: - Download State

enum DownloadState: Equatable {
    case idle
    case downloading(progress: Float, downloadedBytes: Int64, totalBytes: Int64)
    case completed
    case failed(error: String)

    var progressPercent: Int {
        switch self {
        case .downloading(let progress, _, _): return Int(progress * 100)
        default: return 0
        }
    }

    var downloadedDisplay: String {
        switch self {
        case .downloading(_, let downloaded, _):
            return ByteCountFormatter.string(fromByteCount: downloaded, countStyle: .file)
        default: return ""
        }
    }

    var totalDisplay: String {
        switch self {
        case .downloading(_, _, let total):
            return ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
        default: return ""
        }
    }
}

// MARK: - Downloadable Model

struct DownloadableModel: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let sizeDisplay: String
    let sizeBytes: Int64
    let downloadUrl: String
    let fileName: String
    let quantization: String
    let parameters: String
    let category: ModelCategory
    let family: ModelFamily
    let isGated: Bool

    static func == (lhs: DownloadableModel, rhs: DownloadableModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Model Catalog (Sync'd with Android)

enum ModelCatalog {
    static let models: [DownloadableModel] = [
        // ═══════════════════════════════════════════
        // COMPACT MODELS (< 500 MB)
        // ═══════════════════════════════════════════
        DownloadableModel(
            id: "smollm-135m-q8",
            name: "SmolLM 135M",
            description: "Ultra-lightweight 135M model. Blazing fast inference with basic Q&A. Perfect for quick testing on any device.",
            sizeDisplay: "~159 MB",
            sizeBytes: 166_754_726,
            downloadUrl: "https://huggingface.co/litert-community/SmolLM-135M-Instruct/resolve/main/SmolLM-135M-Instruct_multi-prefill-seq_q8_ekv1280.task",
            fileName: "smollm-135m-q8.task",
            quantization: "Q8",
            parameters: "135M",
            category: .small,
            family: .smolLM,
            isGated: false
        ),
        DownloadableModel(
            id: "gemma3-270m-q8",
            name: "Gemma 3 270M",
            description: "Google's tiniest Gemma 3. Surprisingly capable for its size — great for simple tasks and rapid prototyping.",
            sizeDisplay: "~290 MB",
            sizeBytes: 303_950_933,
            downloadUrl: "https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/gemma3-270m-it-q8.task",
            fileName: "gemma3-270m-q8.task",
            quantization: "Q8",
            parameters: "270M",
            category: .small,
            family: .gemma,
            isGated: true
        ),

        // ═══════════════════════════════════════════
        // STANDARD MODELS (500 MB – 1.5 GB)
        // ═══════════════════════════════════════════
        DownloadableModel(
            id: "qwen25-05b-q8",
            name: "Qwen 2.5 0.5B",
            description: "Alibaba's Qwen 2.5 with 0.5B params. Solid reasoning, multilingual support, and great coding skills for its size.",
            sizeDisplay: "~521 MB",
            sizeBytes: 546_660_344,
            downloadUrl: "https://huggingface.co/litert-community/Qwen2.5-0.5B-Instruct/resolve/main/Qwen2.5-0.5B-Instruct_multi-prefill-seq_q8_ekv1280.task",
            fileName: "qwen25-05b-q8.task",
            quantization: "Q8",
            parameters: "0.5B",
            category: .medium,
            family: .qwen,
            isGated: false
        ),
        DownloadableModel(
            id: "smollm-135m-f32",
            name: "SmolLM 135M (F32)",
            description: "Full-precision 135M model. Higher accuracy than Q8 variant but 3x larger. Best quality at the smallest scale.",
            sizeDisplay: "~528 MB",
            sizeBytes: 553_281_294,
            downloadUrl: "https://huggingface.co/litert-community/SmolLM-135M-Instruct/resolve/main/SmolLM-135M-Instruct_multi-prefill-seq_f32_ekv1280.task",
            fileName: "smollm-135m-f32.task",
            quantization: "F32",
            parameters: "135M",
            category: .medium,
            family: .smolLM,
            isGated: false
        ),
        DownloadableModel(
            id: "gemma3-1b-q4",
            name: "Gemma 3 1B (Q4) ⭐",
            description: "Google's Gemma 3 1B quantized to 4-bit. Excellent quality-to-size ratio — compact yet very capable for on-device use.",
            sizeDisplay: "~529 MB",
            sizeBytes: 554_661_243,
            downloadUrl: "https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1b-it-int4.task",
            fileName: "gemma3-1b-q4.task",
            quantization: "Q4",
            parameters: "1B",
            category: .medium,
            family: .gemma,
            isGated: true
        ),
        DownloadableModel(
            id: "gemma3-1b-q8",
            name: "Gemma 3 1B",
            description: "Google's latest Gemma 3 with 1B params. Strong reasoning and instruction following. Optimized for mobile.",
            sizeDisplay: "~1.0 GB",
            sizeBytes: 1_054_012_582,
            downloadUrl: "https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q8_ekv1280.task",
            fileName: "gemma3-1b-q8.task",
            quantization: "Q8",
            parameters: "1B",
            category: .medium,
            family: .gemma,
            isGated: true
        ),
        DownloadableModel(
            id: "tinyllama-1b-q8",
            name: "TinyLlama 1.1B",
            description: "Community-favorite TinyLlama trained on 3T tokens. Punches above its weight in general chat and coding tasks.",
            sizeDisplay: "~1.1 GB",
            sizeBytes: 1_148_331_545,
            downloadUrl: "https://huggingface.co/litert-community/TinyLlama-1.1B-Chat-v1.0/resolve/main/TinyLlama-1.1B-Chat-v1.0_multi-prefill-seq_q8_ekv1280.task",
            fileName: "tinyllama-1b-q8.task",
            quantization: "Q8",
            parameters: "1.1B",
            category: .medium,
            family: .llama,
            isGated: false
        ),

        // ═══════════════════════════════════════════
        // PERFORMANCE MODELS (1.5 – 3 GB)
        // ═══════════════════════════════════════════
        DownloadableModel(
            id: "qwen25-15b-q8",
            name: "Qwen 2.5 1.5B ⭐",
            description: "Top-tier Qwen 2.5 with 1.5B params. Superior logic, coding, math reasoning. Best overall model for on-device use.",
            sizeDisplay: "~1.5 GB",
            sizeBytes: 1_597_913_616,
            downloadUrl: "https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct/resolve/main/Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv1280.task",
            fileName: "qwen25-15b-q8.task",
            quantization: "Q8",
            parameters: "1.5B",
            category: .large,
            family: .qwen,
            isGated: false
        ),
        DownloadableModel(
            id: "qwen25-15b-q8-4k",
            name: "Qwen 2.5 1.5B (4K ctx)",
            description: "Same powerful Qwen 2.5 1.5B with extended 4096-token context window. Handles longer conversations and documents.",
            sizeDisplay: "~1.5 GB",
            sizeBytes: 1_598_556_720,
            downloadUrl: "https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct/resolve/main/Qwen2.5-1.5B-Instruct_multi-prefill-seq_q8_ekv4096.task",
            fileName: "qwen25-15b-q8-4k.task",
            quantization: "Q8",
            parameters: "1.5B",
            category: .large,
            family: .qwen,
            isGated: false
        ),
        DownloadableModel(
            id: "deepseek-r1-15b-q8",
            name: "DeepSeek R1 1.5B ⭐",
            description: "DeepSeek's R1 reasoning model distilled into Qwen 1.5B. Chain-of-thought reasoning for complex problem solving.",
            sizeDisplay: "~1.8 GB",
            sizeBytes: 1_861_094_737,
            downloadUrl: "https://huggingface.co/litert-community/DeepSeek-R1-Distill-Qwen-1.5B/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B_multi-prefill-seq_q8_ekv1280.task",
            fileName: "deepseek-r1-15b-q8.task",
            quantization: "Q8",
            parameters: "1.5B",
            category: .large,
            family: .deepseek,
            isGated: false
        ),
        DownloadableModel(
            id: "deepseek-r1-15b-q8-4k",
            name: "DeepSeek R1 1.5B (4K ctx)",
            description: "DeepSeek R1 with extended 4K context. Perfect for detailed reasoning chains and complex multi-step problems.",
            sizeDisplay: "~1.7 GB",
            sizeBytes: 1_834_078_546,
            downloadUrl: "https://huggingface.co/litert-community/DeepSeek-R1-Distill-Qwen-1.5B/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B_multi-prefill-seq_q8_ekv4096.task",
            fileName: "deepseek-r1-15b-q8-4k.task",
            quantization: "Q8",
            parameters: "1.5B",
            category: .large,
            family: .deepseek,
            isGated: false
        ),
        DownloadableModel(
            id: "gemma4-e2b-web",
            name: "Gemma 4 E2B 🆕",
            description: "Google's latest Gemma 4 multimodal model. State-of-the-art reasoning with text, vision & audio understanding.",
            sizeDisplay: "~1.9 GB",
            sizeBytes: 2_003_697_664,
            downloadUrl: "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it-web.task",
            fileName: "gemma4-e2b.task",
            quantization: "Q8",
            parameters: "2B",
            category: .large,
            family: .gemma,
            isGated: false
        ),
        DownloadableModel(
            id: "qwen25-05b-f32",
            name: "Qwen 2.5 0.5B (F32)",
            description: "Full-precision Qwen 0.5B. Maximum accuracy with no quantization loss. Great for tasks requiring precision.",
            sizeDisplay: "~1.9 GB",
            sizeBytes: 1_991_044_308,
            downloadUrl: "https://huggingface.co/litert-community/Qwen2.5-0.5B-Instruct/resolve/main/Qwen2.5-0.5B-Instruct_multi-prefill-seq_f32_ekv1280.task",
            fileName: "qwen25-05b-f32.task",
            quantization: "F32",
            parameters: "0.5B",
            category: .large,
            family: .qwen,
            isGated: false
        ),
        DownloadableModel(
            id: "gemma2-2b-q8",
            name: "Gemma 2 2B",
            description: "Google's Gemma 2 with 2B params. Strong general-purpose conversational AI with solid instruction following.",
            sizeDisplay: "~2.6 GB",
            sizeBytes: 2_713_274_466,
            downloadUrl: "https://huggingface.co/litert-community/Gemma2-2B-IT/resolve/main/Gemma2-2B-IT_multi-prefill-seq_q8_ekv1280.task",
            fileName: "gemma2-2b-q8.task",
            quantization: "Q8",
            parameters: "2B",
            category: .large,
            family: .gemma,
            isGated: true
        ),

        // ═══════════════════════════════════════════
        // FLAGSHIP MODELS (3+ GB)
        // ═══════════════════════════════════════════
        DownloadableModel(
            id: "gemma4-e4b-web",
            name: "Gemma 4 E4B 🆕",
            description: "Google's flagship Gemma 4 E4B. The most capable on-device Gemma model — exceptional reasoning, coding & analysis.",
            sizeDisplay: "~2.8 GB",
            sizeBytes: 2_964_324_352,
            downloadUrl: "https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it-web.task",
            fileName: "gemma4-e4b.task",
            quantization: "Q8",
            parameters: "4B",
            category: .extraLarge,
            family: .gemma,
            isGated: false
        ),
        DownloadableModel(
            id: "phi4-mini-q8",
            name: "Phi-4 Mini 3.8B",
            description: "Microsoft's Phi-4 Mini with 3.8B params. State-of-the-art reasoning, math & coding among open models.",
            sizeDisplay: "~3.7 GB",
            sizeBytes: 3_944_275_882,
            downloadUrl: "https://huggingface.co/litert-community/Phi-4-mini-instruct/resolve/main/Phi-4-mini-instruct_multi-prefill-seq_q8_ekv1280.task",
            fileName: "phi4-mini-q8.task",
            quantization: "Q8",
            parameters: "3.8B",
            category: .extraLarge,
            family: .phi,
            isGated: false
        ),
        DownloadableModel(
            id: "phi4-mini-q8-4k",
            name: "Phi-4 Mini 3.8B (4K ctx)",
            description: "Phi-4 Mini with extended 4096-token context. Handles long documents, detailed code analysis & extended conversations.",
            sizeDisplay: "~3.7 GB",
            sizeBytes: 3_910_050_199,
            downloadUrl: "https://huggingface.co/litert-community/Phi-4-mini-instruct/resolve/main/Phi-4-mini-instruct_multi-prefill-seq_q8_ekv4096.task",
            fileName: "phi4-mini-q8-4k.task",
            quantization: "Q8",
            parameters: "3.8B",
            category: .extraLarge,
            family: .phi,
            isGated: false
        )
    ]
}
