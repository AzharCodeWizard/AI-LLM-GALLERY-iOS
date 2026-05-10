//
//  CapabilityCard.swift
//  AI LLM GALLERY
//

import SwiftUI

struct CapabilityCard: View {
    let capability: AiCapability
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ── Icon Badge ──
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: capability.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
            }

            // ── Title ──
            Text(capability.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)

            // ── Description ──
            Text(capability.description)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(3)

            Spacer(minLength: 0)

            // ── Tags ──
            HStack(spacing: 6) {
                tagView(text: capability.category.rawValue)
                if capability.requiresImageInput {
                    tagView(text: "Image Input")
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 190)
        .background(
            LinearGradient(
                colors: capability.category.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(
            color: capability.category.gradientColors[0].opacity(0.25),
            radius: 10,
            y: 5
        )
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }

    private func tagView(text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.white.opacity(0.2))
            .clipShape(Capsule())
    }
}
