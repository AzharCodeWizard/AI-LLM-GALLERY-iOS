//
//  ModelDownloadView.swift
//  AI LLM GALLERY
//

import SwiftUI

struct ModelDownloadView: View {
    let onBack: () -> Void

    @StateObject private var viewModel = ModelDownloadViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                let grouped = Dictionary(grouping: viewModel.models) { $0.category }
                let categoryOrder: [ModelCategory] = [.small, .medium, .large, .extraLarge]

                ForEach(categoryOrder, id: \.self) { category in
                    if let models = grouped[category] {
                        sectionHeader(title: category.displayName, count: models.count)

                        ForEach(models) { model in
                            let isDownloaded = viewModel.downloadedModelIds.contains(model.id)
                            let state = viewModel.downloadStates[model.id] ?? .idle
                            modelCard(model: model, isDownloaded: isDownloaded, downloadState: state)
                        }
                    }
                }
                Spacer().frame(height: 16)
            }
            .padding(16)
        }
        .background(Color.appBackground)
        .navigationTitle("Model Hub")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)).foregroundColor(.appPrimary)
                }
            }
        }
    }

    private func sectionHeader(title: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(.appPrimary)
            Text("\(count)").font(.system(size: 11, weight: .medium)).foregroundColor(.appOnPrimaryContainer)
                .padding(.horizontal, 8).padding(.vertical, 2).background(Capsule().fill(Color.appPrimaryContainer))
            Spacer()
        }.padding(.vertical, 8)
    }

    private func modelCard(model: DownloadableModel, isDownloaded: Bool, downloadState: DownloadState) -> some View {
        let isDownloading = { if case .downloading = downloadState { return true }; return false }()

        return VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Text(model.family.emoji).font(.system(size: 14)).padding(.horizontal, 6).padding(.vertical, 2).background(RoundedRectangle(cornerRadius: 6).fill(Color.appSurfaceVariant))
                Text(model.name).font(.system(size: 16, weight: .semibold)).foregroundColor(.appOnSurface).lineLimit(1)
                if isDownloaded { Image(systemName: "checkmark.circle.fill").font(.system(size: 16)).foregroundColor(.appPrimary) }
                Spacer()
            }
            Text(model.description).font(.system(size: 12)).foregroundColor(.appOnSurfaceVariant).lineLimit(2)

            // Specs
            HStack(spacing: 8) {
                specChip(icon: "cpu", text: model.parameters)
                specChip(icon: "speedometer", text: model.quantization)
                specChip(icon: "arrow.down.circle", text: model.sizeDisplay)
            }

            // Progress
            if case .downloading(let progress, let downloaded, let total) = downloadState {
                VStack(spacing: 6) {
                    ProgressView(value: progress)
                        .tint(.appPrimary)
                    HStack {
                        Text("\(ByteCountFormatter.string(fromByteCount: downloaded, countStyle: .file)) / \(ByteCountFormatter.string(fromByteCount: total, countStyle: .file))").font(.system(size: 11)).foregroundColor(.appOnSurfaceVariant)
                        Spacer()
                        Text("\(Int(progress * 100))%").font(.system(size: 11, weight: .semibold)).foregroundColor(.appPrimary)
                    }
                }
            }

            // Error
            if case .failed(let error) = downloadState {
                Text("⚠️ \(error)").font(.system(size: 11)).foregroundColor(.appError).padding(8).frame(maxWidth: .infinity, alignment: .leading).background(RoundedRectangle(cornerRadius: 8).fill(Color.appErrorContainer.opacity(0.5)))
            }

            // Actions
            HStack {
                Spacer()
                if isDownloading {
                    Button(action: { viewModel.cancelDownload(model.id) }) {
                        HStack(spacing: 6) { Image(systemName: "xmark").font(.system(size: 13)); Text("Cancel").font(.system(size: 13, weight: .medium)) }
                        .foregroundColor(.appOnSurface).padding(.horizontal, 16).padding(.vertical, 10).background(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline, lineWidth: 1))
                    }
                } else if isDownloaded {
                    Button(action: { viewModel.deleteModel(model) }) {
                        HStack(spacing: 6) { Image(systemName: "trash").font(.system(size: 13)); Text("Delete").font(.system(size: 13, weight: .medium)) }
                        .foregroundColor(.appError).padding(.horizontal, 16).padding(.vertical, 10).background(RoundedRectangle(cornerRadius: 12).fill(Color.appErrorContainer.opacity(0.6)))
                    }
                } else if model.isGated {
                    Button(action: {}) {
                        HStack(spacing: 6) { Text("🔒"); Text("Requires Login").font(.system(size: 13, weight: .medium)) }
                        .foregroundColor(.appOnSurface).padding(.horizontal, 16).padding(.vertical, 10).background(RoundedRectangle(cornerRadius: 12).stroke(Color.appOutline, lineWidth: 1))
                    }
                } else {
                    Button(action: { viewModel.downloadModel(model) }) {
                        HStack(spacing: 8) { Image(systemName: "arrow.down.circle").font(.system(size: 15)); Text("Download").font(.system(size: 14, weight: .semibold)) }
                        .foregroundColor(.appOnPrimary).padding(.horizontal, 20).padding(.vertical, 10).background(Color.appPrimary).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDownloaded ? Color.appPrimaryContainer.opacity(0.3) : Color.appSurfaceVariant.opacity(0.5))
        )
    }

    private func specChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 11)).foregroundColor(.appOnSurfaceVariant)
            Text(text).font(.system(size: 11)).foregroundColor(.appOnSurfaceVariant)
        }.padding(.horizontal, 10).padding(.vertical, 4).background(RoundedRectangle(cornerRadius: 8).fill(Color.appSurface.opacity(0.8)))
    }
}
