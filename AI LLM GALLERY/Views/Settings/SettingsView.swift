import SwiftUI

struct SettingsView: View {
    let onBack: () -> Void
    let onModelHubClick: () -> Void

    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader("Active Model")
                settingsCard {
                    settingsItem(icon: "cpu", title: "Current AI Engine", subtitle: viewModel.activeModelName)
                }

                sectionHeader("Model Hub")
                settingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Authentication (Optional)")
                            .font(.system(size: 14, weight: .medium)).foregroundColor(.appOnSurface)
                        
                        SecureField("Paste Hugging Face Token (hf_...)", text: Binding(
                            get: { UserDefaults.standard.string(forKey: "hfToken") ?? "" },
                            set: { UserDefaults.standard.set($0, forKey: "hfToken") }
                        ))
                        .font(.system(size: 14))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.appOutline, lineWidth: 1))
                        
                        Text("Required for gated models like Gemma 3.")
                            .font(.system(size: 11)).foregroundColor(.appOnSurfaceVariant)
                    }
                    .padding(16)
                }

                Button(action: onModelHubClick) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle").font(.system(size: 17))
                        Text("Browse & Download Models").font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.appOnPrimary)
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(Color.appPrimary).clipShape(RoundedRectangle(cornerRadius: 16))
                }

                sectionHeader("Downloaded Models (\(viewModel.downloadedModels.count))")
                if viewModel.downloadedModels.isEmpty {
                    settingsCard {
                        settingsItem(icon: "folder", title: "No models downloaded", subtitle: "Tap \"Browse & Download Models\" above to get started.")
                    }
                } else {
                    settingsCard {
                        ForEach(viewModel.downloadedModels, id: \.absoluteString) { fileURL in
                            let name = fileURL.deletingPathExtension().lastPathComponent
                            let isActive = viewModel.activeModelName.localizedCaseInsensitiveContains(name)
                            let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0

                            HStack(spacing: 16) {
                                Image(systemName: isActive ? "cpu" : "folder").font(.system(size: 18)).foregroundColor(.appPrimary).frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(name + (isActive ? " ✓ Active" : "")).font(.system(size: 14, weight: .medium)).foregroundColor(.appOnSurface)
                                    Text("\(size / 1024 / 1024) MB" + (isActive ? "" : " • Tap to activate")).font(.system(size: 12)).foregroundColor(.appOnSurfaceVariant)
                                }
                                Spacer()
                                Button(action: { viewModel.deleteModel(fileURL) }) {
                                    Image(systemName: "trash").font(.system(size: 15)).foregroundColor(.appError)
                                }
                            }
                            .padding(16)
                            .contentShape(Rectangle())
                            .onTapGesture { viewModel.selectModel(fileURL) }
                        }
                    }
                    Button(action: { viewModel.clearAllModels() }) {
                        Text("Clear All Models").font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appError).frame(maxWidth: .infinity).frame(height: 44)
                            .background(Color.appErrorContainer).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                sectionHeader("Manual Model Setup")
                settingsCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You can manually transfer .task or .bin models via Finder/iTunes File Sharing into the app's Documents/models folder.")
                            .font(.system(size: 13)).foregroundColor(.appOnSurface)
                        Text("The app automatically detects new models.")
                            .font(.system(size: 12)).foregroundColor(.appOnSurfaceVariant)
                    }.padding(16)
                }

                sectionHeader("About")
                settingsCard {
                    VStack(spacing: 0) {
                        settingsItem(icon: "info.circle", title: "AI LLM Gallery", subtitle: "Version 1.0 • Premium On-device AI")
                        Divider().padding(.horizontal, 16)
                        settingsItem(icon: "chevron.left.forwardslash.chevron.right", title: "Tech Stack", subtitle: "Swift • SwiftUI • MediaPipe • SwiftData")
                        Divider().padding(.horizontal, 16)
                        settingsItem(icon: "ant", title: "Architecture", subtitle: "NavigationStack • MVVM • Async/Await • URLSession")
                    }
                }

                sectionHeader("Developer")
                settingsCard {
                    settingsItem(icon: "chevron.left.forwardslash.chevron.right", title: "Developed by Azhar", subtitle: "Made with ❤️ in India 🇮🇳")
                }

                Spacer().frame(height: 16)
            }
            .padding(.horizontal, 16)
        }
        .background(Color.appBackground)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) { Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)).foregroundColor(.appPrimary) }
            }
        }
        .onAppear { viewModel.refreshModels() }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(.appPrimary).padding(.top, 8)
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.appSurfaceVariant.opacity(0.4)))
    }

    private func settingsItem(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(.appPrimary).frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14, weight: .medium)).foregroundColor(.appOnSurface)
                Text(subtitle).font(.system(size: 12)).foregroundColor(.appOnSurfaceVariant)
            }
            Spacer()
        }.padding(16)
    }
}
