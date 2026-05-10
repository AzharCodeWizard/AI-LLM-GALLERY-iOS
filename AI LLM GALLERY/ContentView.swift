//
//  ContentView.swift
//  AI LLM GALLERY
//
//  This file is no longer used — the app entry point is now AppNavigation.
//  Kept for backwards compatibility with Xcode file references.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        AppNavigation()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Quiz.self, Question.self, Story.self])
}
