//
//  GalleryViewModel.swift
//  AI LLM GALLERY
//

import SwiftUI
import Combine

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var selectedCategory: CapabilityCategory = .all
    @Published var searchText = ""

    let allCapabilities = AiCapabilities.all

    var filteredCapabilities: [AiCapability] {
        var result = allCapabilities

        if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }
}
