//
//  GalleryView.swift
//  CamShot
//
//  Created by Elizbar Kheladze on 08/12/25.
//

import SwiftData
import SwiftUI

struct GalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    @State private var showCapture = false

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(destination: ItemDetailView(selectedID: item.id)) {
                            if let uiImage = UIImage(data: item.imageData) {
                                PolaroidFrame(
                                    image: uiImage,
                                    audioData: item.audioData,
                                    blurAmount: 0,
                                    showAudioControls: true,
                                    enableShadow: true,
                                    isCompact: true
                                )
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.black)
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func deleteItem(_ item: Item) {
        withAnimation {
            modelContext.delete(item)
        }
    }
}
