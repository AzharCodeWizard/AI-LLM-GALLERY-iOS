//
//  MessageBubble.swift
//  AI LLM GALLERY
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
                userBubble
            } else {
                aiBubble
                Spacer(minLength: 60)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - User Bubble

    private var userBubble: some View {
        VStack(alignment: .trailing, spacing: 6) {
            // Image attachment
            if let image = message.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 200, maxHeight: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Text(message.text)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Color.appPrimary
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
        }
    }

    // MARK: - AI Bubble

    private var aiBubble: some View {
        VStack(alignment: .leading, spacing: 6) {
            // AI avatar
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color.appPrimaryContainer)
                        .frame(width: 24, height: 24)

                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.appOnPrimaryContainer)
                }

                Text("AI")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appOnSurfaceVariant)
            }

            if message.isStreaming && message.text.isEmpty {
                // Typing indicator
                typingIndicator
            } else {
                // Response text with proper rendering
                Text(markdownAttributedString(message.text))
                    .font(.system(size: 15))
                    .foregroundColor(.appOnSurface)
                    .textSelection(.enabled)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Color.appSurfaceVariant.opacity(0.5)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
            }

            // Inference time badge
            if let inferenceTime = message.inferenceTimeMs, !message.isStreaming {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(formatInferenceTime(inferenceTime))
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.appOnSurfaceVariant.opacity(0.6))
                .padding(.leading, 8)
            }
        }
    }

    // MARK: - Typing Indicator

    private var typingIndicator: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.appOnSurfaceVariant.opacity(0.4))
                    .frame(width: 8, height: 8)
                    .modifier(TypingDotAnimation(delay: Double(index) * 0.2))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.appSurfaceVariant.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    /// Safely parse markdown to AttributedString, fall back to plain text if parsing fails.
    private func markdownAttributedString(_ text: String) -> AttributedString {
        if let attributed = try? AttributedString(
            markdown: text,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return attributed
        }
        return AttributedString(text)
    }

    private func formatInferenceTime(_ ms: Int64) -> String {
        if ms < 1000 {
            return "\(ms) ms"
        } else {
            let seconds = Double(ms) / 1000.0
            return String(format: "%.1f s", seconds)
        }
    }
}

// MARK: - Typing Dot Animation

struct TypingDotAnimation: ViewModifier {
    let delay: Double
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .offset(y: isAnimating ? -4 : 2)
            .animation(
                Animation.easeInOut(duration: 0.5)
                    .repeatForever()
                    .delay(delay),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}
