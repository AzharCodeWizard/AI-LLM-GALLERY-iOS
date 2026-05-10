//
//  AppNavigation.swift
//  AI LLM GALLERY
//
//  NavigationStack-based routing matching Android Nav3 architecture.
//

import SwiftUI

// MARK: - Navigation Route

enum AppRoute: Hashable {
    case gallery
    case chat(capabilityId: String, capabilityTitle: String)
    case settings
    case modelDownload
    case quizList
    case quizPlay(quizId: String)
    case story
}

// MARK: - App Navigation

struct AppNavigation: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            GalleryView(
                onCapabilityTap: { capability in
                    path.append(AppRoute.chat(
                        capabilityId: capability.id,
                        capabilityTitle: capability.title
                    ))
                },
                onSettingsTap: {
                    path.append(AppRoute.settings)
                },
                onQuizTap: {
                    path.append(AppRoute.quizList)
                },
                onStoryTap: {
                    path.append(AppRoute.story)
                }
            )
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .gallery:
                    EmptyView() // Root, not pushed

                case .chat(let capabilityId, let title):
                    ChatView(
                        capabilityId: capabilityId,
                        capabilityTitle: title,
                        onBack: { path.removeLast() }
                    )

                case .settings:
                    SettingsView(
                        onBack: { path.removeLast() },
                        onModelHubClick: { path.append(AppRoute.modelDownload) }
                    )

                case .modelDownload:
                    ModelDownloadView(
                        onBack: { path.removeLast() }
                    )

                case .quizList:
                    QuizListView(
                        onBack: { path.removeLast() },
                        onQuizPlay: { quizId in
                            path.append(AppRoute.quizPlay(quizId: quizId))
                        }
                    )

                case .quizPlay(let quizId):
                    QuizPlayView(
                        quizId: quizId,
                        onBack: { path.removeLast() }
                    )

                case .story:
                    StoryView(
                        onBack: { path.removeLast() }
                    )
                }
            }
        }
    }
}
