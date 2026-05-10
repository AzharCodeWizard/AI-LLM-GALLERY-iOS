//
//  AI_LLM_GALLERYApp.swift
//  AI LLM GALLERY
//
//  Created by Azhar on 10/05/26.
//

import SwiftUI
import SwiftData

@main
struct AI_LLM_GALLERYApp: App {

    init() {
        // Ensure Application Support directory exists before SwiftData tries to create the store
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        if !FileManager.default.fileExists(atPath: appSupport.path) {
            try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        }
    }

    var body: some Scene {
        WindowGroup {
            AppNavigation()
        }
        .modelContainer(for: [Quiz.self, Question.self, Story.self])
    }
}
