//
//  StoryView.swift
//  AI LLM GALLERY
//

import SwiftUI
import SwiftData

struct StoryView: View {
    let onBack: () -> Void

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = StoryViewModel()
    @State private var newTopic = ""
    @State private var selectedGenre = "Fantasy"

    var body: some View {
        Group {
            if let story = viewModel.currentStory {
                readerView(story: story)
            } else {
                listView
            }
        }
        .background(Color.appBackground)
        .navigationTitle(viewModel.currentStory != nil ? "Reader" : "Audio Scripts")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    if viewModel.currentStory != nil { viewModel.clearCurrentStory() }
                    else { onBack() }
                }) {
                    Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold)).foregroundColor(.appPrimary)
                }
            }
        }
        .onAppear { viewModel.setModelContext(modelContext) }
    }

    // MARK: - List View
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Generator Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        ZStack { Circle().fill(Color.appPrimaryContainer).frame(width: 44, height: 44); Image(systemName: "square.and.pencil").font(.system(size: 20, weight: .medium)).foregroundColor(.appOnPrimaryContainer) }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Create a Script").font(.system(size: 20, weight: .bold)).foregroundColor(.appOnSurface)
                            Text("Generate scripts, lyrics & poems with AI").font(.system(size: 12)).foregroundColor(.appOnSurfaceVariant)
                        }
                    }

                    TextField("e.g. A robot learning to paint", text: $newTopic)
                        .font(.system(size: 15)).padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.appSurface.opacity(0.5)).stroke(Color.appOutline.opacity(0.3), lineWidth: 1))
                        .disabled(viewModel.isGenerating)

                    // Genre chips
                    Text("Genre").font(.system(size: 12, weight: .semibold)).foregroundColor(.appOnSurfaceVariant)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(StoryViewModel.genres, id: \.self) { genre in
                                Button(action: { selectedGenre = genre }) {
                                    Text(genre).font(.system(size: 13, weight: selectedGenre == genre ? .semibold : .medium))
                                        .foregroundColor(selectedGenre == genre ? .appOnPrimary : .appOnSurfaceVariant)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(selectedGenre == genre ? Color.appPrimary : Color.appSurface)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(selectedGenre == genre ? Color.clear : Color.appOutline.opacity(0.3), lineWidth: 1))
                                }.buttonStyle(.plain)
                            }
                        }
                    }

                    if let error = viewModel.error {
                        Text(error).font(.system(size: 12)).foregroundColor(.appError)
                    }

                    HStack {
                        Spacer()
                        Button(action: { if !newTopic.isEmpty { viewModel.generateStory(promptTopic: newTopic, genre: selectedGenre); newTopic = "" } }) {
                            HStack(spacing: 8) {
                                if viewModel.isGenerating { ProgressView().scaleEffect(0.8).tint(.white); Text("Writing...").font(.system(size: 14, weight: .semibold)) }
                                else { Text("Generate Script").font(.system(size: 14, weight: .semibold)) }
                            }.foregroundColor(.appOnPrimary).padding(.horizontal, 24).padding(.vertical, 12)
                            .background((!viewModel.isGenerating && !newTopic.isEmpty) ? Color.appPrimary : Color.appOnSurface.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }.disabled(viewModel.isGenerating || newTopic.isEmpty)
                    }
                }.padding(24).background(RoundedRectangle(cornerRadius: 24).fill(Color.appSurfaceVariant.opacity(0.4))).padding(16)

                // Story list
                if viewModel.stories.isEmpty && !viewModel.isGenerating {
                    VStack(spacing: 16) {
                        Image(systemName: "book").font(.system(size: 48)).foregroundColor(.appOnSurfaceVariant.opacity(0.3))
                        Text("No stories yet").font(.system(size: 18, weight: .semibold)).foregroundColor(.appOnSurfaceVariant)
                        Text("Generate your first audio script above!").font(.system(size: 13)).foregroundColor(.appOnSurfaceVariant.opacity(0.6))
                    }.padding(48)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.stories, id: \.persistentModelID) { story in
                            storyCard(story: story)
                        }
                    }.padding(.horizontal, 16).padding(.bottom, 24)
                }
            }
        }
    }

    // MARK: - Reader View
    private func readerView(story: Story) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 16)
                Text(story.title).font(.system(size: 32, weight: .bold)).foregroundColor(.appPrimary).padding(.horizontal, 24)
                Spacer().frame(height: 8)

                HStack(spacing: 12) {
                    Text(story.genre).font(.system(size: 12, weight: .medium)).foregroundColor(.appOnSecondaryContainer).padding(.horizontal, 10).padding(.vertical, 4).background(RoundedRectangle(cornerRadius: 6).fill(Color.appSecondaryContainer))
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2.fill").font(.system(size: 12)).foregroundColor(AppColors.success)
                        Text("Voice ready").font(.system(size: 11)).foregroundColor(AppColors.success)
                    }
                }.padding(.horizontal, 24)

                Spacer().frame(height: 32)

                let isSongOrPoem = ["Song Lyrics", "Poem"].contains(story.genre)
                Text(story.content).font(.system(size: isSongOrPoem ? 16 : 18)).lineSpacing(isSongOrPoem ? 6 : 8).foregroundColor(.appOnSurface).padding(.horizontal, 24)

                Spacer().frame(height: 100)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            // TTS FAB
            Button(action: {
                if viewModel.ttsManager.isPlaying { viewModel.stopStory() }
                else { viewModel.playStory() }
            }) {
                Image(systemName: viewModel.ttsManager.isPlaying ? "stop.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(viewModel.ttsManager.isPlaying ? .white : .appOnPrimaryContainer)
                    .frame(width: 56, height: 56)
                    .background(viewModel.ttsManager.isPlaying ? Color.red : Color.appPrimaryContainer)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            }
            .padding(24)
        }
    }

    // MARK: - Story Card
    private func storyCard(story: Story) -> some View {
        Button(action: { viewModel.loadStory(story) }) {
            HStack(spacing: 14) {
                ZStack { RoundedRectangle(cornerRadius: 14).fill(Color.appPrimaryContainer).frame(width: 52, height: 52); Image(systemName: "book").font(.system(size: 22, weight: .medium)).foregroundColor(.appOnPrimaryContainer) }
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.title).font(.system(size: 16, weight: .bold)).foregroundColor(.appOnSurface).lineLimit(2)
                    HStack(spacing: 6) {
                        Text(story.genre).font(.system(size: 11, weight: .semibold)).foregroundColor(.appOnTertiaryContainer).padding(.horizontal, 8).padding(.vertical, 2).background(RoundedRectangle(cornerRadius: 6).fill(Color.appTertiaryContainer))
                        Text(story.timestamp.formatted(date: .abbreviated, time: .omitted)).font(.system(size: 11)).foregroundColor(.appOnSurfaceVariant)
                    }
                }
                Spacer()
                Button(action: { viewModel.deleteStory(story) }) { Image(systemName: "trash").font(.system(size: 15)).foregroundColor(.appError.opacity(0.7)) }
            }.padding(16).background(RoundedRectangle(cornerRadius: 20).fill(Color.appSurface).shadow(color: .black.opacity(0.04), radius: 4, y: 2))
        }.buttonStyle(.plain)
    }
}
