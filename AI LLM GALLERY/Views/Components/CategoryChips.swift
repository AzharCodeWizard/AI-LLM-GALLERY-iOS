//
//  CategoryChips.swift
//  AI LLM GALLERY
//

import SwiftUI

struct CategoryChips: View {
    @Binding var selectedCategory: CapabilityCategory
    let categories: [CapabilityCategory]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    chipView(category: category)
                }
            }
        }
    }

    private func chipView(category: CapabilityCategory) -> some View {
        let isSelected = selectedCategory == category

        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = category
            }
        }) {
            Text(category.rawValue)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .appOnPrimary : .appOnSurfaceVariant)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    isSelected
                        ? AnyShapeStyle(Color.appPrimary)
                        : AnyShapeStyle(Color.appSurface)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : Color.appOutline.opacity(0.3),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
