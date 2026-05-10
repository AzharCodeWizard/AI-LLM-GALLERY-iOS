//
//  ChatView.swift
//  AI LLM GALLERY
//

import SwiftUI
import PhotosUI

struct ChatView: View {
    let capabilityId: String
    let capabilityTitle: String
    let onBack: () -> Void

    @StateObject private var viewModel: ChatViewModel
    @State private var inputText = ""
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    init(capabilityId: String, capabilityTitle: String, onBack: @escaping () -> Void) {
        self.capabilityId = capabilityId
        self.capabilityTitle = capabilityTitle
        self.onBack = onBack
        _viewModel = StateObject(wrappedValue: ChatViewModel(capabilityId: capabilityId))
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Messages ──
            if viewModel.messages.isEmpty {
                emptyState
            } else {
                messagesList
            }

            // ── Input Bar ──
            ChatInputBar(
                text: $inputText,
                selectedImage: $viewModel.selectedImage,
                isLoading: viewModel.isLoading,
                showImagePicker: viewModel.requiresImageInput,
                onSend: {
                    let text = inputText
                    inputText = ""
                    viewModel.sendMessage(text)
                },
                onImagePicked: { item in
                    selectedPhotoItem = item
                }
            )
        }
        .background(Color.appBackground)
        .navigationTitle(capabilityTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive, action: { viewModel.clearChat() }) {
                        Label("Clear Chat", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.appOnSurfaceVariant)
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.selectedImage = image
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.appPrimaryContainer.opacity(0.3))
                    .frame(width: 80, height: 80)

                Image(systemName: "sparkles")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.appPrimary)
            }

            VStack(spacing: 8) {
                Text("Start a conversation")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appOnSurface)

                Text("Model: \(viewModel.modelStatusText)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appOnSurfaceVariant)
            }

            // Example prompts
            let capability = AiCapabilities.all.first { $0.id == capabilityId }
            if let prompts = capability?.examplePrompts {
                VStack(spacing: 10) {
                    ForEach(prompts, id: \.self) { prompt in
                        Button(action: {
                            inputText = prompt
                        }) {
                            HStack {
                                Image(systemName: "sparkle")
                                    .font(.system(size: 12))
                                    .foregroundColor(.appPrimary)

                                Text(prompt)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.appOnSurface)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)

                                Spacer()
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.appSurfaceVariant.opacity(0.5))
                                    .stroke(Color.appOutline.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()
        }
    }

    // MARK: - Messages List

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                if let lastId = viewModel.messages.last?.id {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.messages.last?.text) { _, _ in
                if let lastId = viewModel.messages.last?.id {
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            }
        }
    }
}
