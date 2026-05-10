//
//  ChatInputBar.swift
//  AI LLM GALLERY
//

import SwiftUI
import PhotosUI

struct ChatInputBar: View {
    @Binding var text: String
    @Binding var selectedImage: UIImage?
    let isLoading: Bool
    let showImagePicker: Bool
    let onSend: () -> Void
    let onImagePicked: (PhotosPickerItem?) -> Void

    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.appOutline.opacity(0.2))

            // Image preview
            if let image = selectedImage {
                HStack {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Button(action: { selectedImage = nil }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .background(Circle().fill(.black.opacity(0.5)))
                        }
                        .offset(x: 4, y: -4)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }

            HStack(spacing: 10) {
                // Image picker button
                if showImagePicker {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        Image(systemName: "photo")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.appPrimary)
                            .frame(width: 40, height: 40)
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        onImagePicked(newItem)
                    }
                }

                // Text field
                HStack {
                    TextField("Type a message...", text: $text, axis: .vertical)
                        .font(.system(size: 15))
                        .lineLimit(1...5)
                        .disabled(isLoading)

                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.appSurfaceVariant.opacity(0.5))
                )

                // Send button
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(
                            text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading
                                ? .appOutline
                                : .appPrimary
                        )
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .padding(.bottom, 4)
        }
        .background(Color.appSurface)
    }
}
