//
//  ImageEditorView.swift
//  LookBook
//
//  Created by Екатерина Збарская on 30.05.2025.
//

import SwiftUI

struct ImageEditorView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode

    var initialClothingItems: [ClothingItemPlacement] = []
    var onSave: (([ClothingItemPlacement], Data?) -> Void)? = nil

    @State private var clothingItems: [ClothingItemPlacement]
    @State private var showItemsSheet = false
    @State private var selectedImageID: UUID? = nil

    @EnvironmentObject var clothingViewModel: ClothingViewModel
    
    init(initialClothingItems: [ClothingItemPlacement] = [], onSave: (([ClothingItemPlacement], Data?) -> Void)? = nil) {
        self.initialClothingItems = initialClothingItems
        self.onSave = onSave
        self._clothingItems = State(initialValue: initialClothingItems)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack() {
                GeometryReader { geo in
                    Canvas { context, size in }
                }
                .frame(width: 400, height: 520)
                .background(Color.white)
                .overlay(
                    ZStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedImageID = nil
                            }
                        // Сначала все невыбранные
                        ForEach(clothingItems.indices.filter { clothingItems[$0].id != selectedImageID }, id: \.self) { index in
                            if let clothingItem = clothingViewModel.items.first(where: { $0.id == clothingItems[index].id }),
                               let uiImage = UIImage(data: clothingItem.imageData) {
                                DraggableImageView(
                                    item: $clothingItems[index],
                                    uiImage: uiImage,
                                    isSelected: Binding(
                                        get: { selectedImageID == clothingItems[index].id },
                                        set: { newValue in
                                            selectedImageID = newValue ? clothingItems[index].id : nil
                                        }
                                    ),
                                    onRemove: {
                                        if selectedImageID == clothingItems[index].id {
                                            selectedImageID = nil
                                        }
                                        clothingItems.remove(at: index)
                                    }
                                )
                            }
                        }
                        // Затем выбранная сверху
                        ForEach(clothingItems.indices.filter { clothingItems[$0].id == selectedImageID }, id: \.self) { index in
                            if let clothingItem = clothingViewModel.items.first(where: { $0.id == clothingItems[index].id }),
                               let uiImage = UIImage(data: clothingItem.imageData) {
                                DraggableImageView(
                                    item: $clothingItems[index],
                                    uiImage: uiImage,
                                    isSelected: Binding(
                                        get: { selectedImageID == clothingItems[index].id },
                                        set: { newValue in
                                            selectedImageID = newValue ? clothingItems[index].id : nil
                                        }
                                    ),
                                    onRemove: {
                                        if selectedImageID == clothingItems[index].id {
                                            selectedImageID = nil
                                        }
                                        clothingItems.remove(at: index)
                                    }
                                )
                            }
                        }
                    }
                )
            }
            .clipShape(Rectangle())
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Создать образ")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let snapshot = captureCanvas()
                        onSave?(clothingItems, snapshot)
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.black)
                    }
                }
            }
            ShoppingSheet(isOpen: $showItemsSheet,
                          maxHeight: UIScreen.main.bounds.height * 0.75,
                          minHeight: UIScreen.main.bounds.height * 0.25) {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(clothingViewModel.items, id: \.id) { clothingItem in
                            if let uiImage = UIImage(data: clothingItem.imageData) {
                                let isAlreadyAdded = clothingItems.contains(where: { $0.id == clothingItem.id })
                                Button(action: {
                                    guard !isAlreadyAdded else { return }
                                    if let uiImage = UIImage(data: clothingItem.imageData) {
                                        let aspectRatio = uiImage.size.width / uiImage.size.height
                                        let baseWidth: CGFloat = 150
                                        let baseHeight: CGFloat = baseWidth / aspectRatio
                                        let newItem = ClothingItemPlacement(
                                            id: clothingItem.id,
                                            position: .zero,
                                            size: CGSize(width: baseWidth, height: baseHeight)
                                        )
                                        clothingItems.append(newItem)
                                        selectedImageID = newItem.id
                                        showItemsSheet = false
                                    }
                                }) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 90)
                                        .opacity(isAlreadyAdded ? 0.4 : 1.0)
                                        .cornerRadius(8)
                                }
                                .disabled(isAlreadyAdded)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private func captureCanvas() -> Data? {
        let canvasSize = CGSize(width: 400, height: 530)
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let image = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: canvasSize))

            for item in clothingItems {
                if let clothingItem = clothingViewModel.items.first(where: { $0.id == item.id }),
                   let uiImage = UIImage(data: clothingItem.imageData) {
                    let scaledSize = item.size
                    let center = CGPoint(x: canvasSize.width/2 + item.position.x, y: canvasSize.height/2 + item.position.y)
                    let imageRect = CGRect(
                        x: center.x - scaledSize.width/2,
                        y: center.y - scaledSize.height/2,
                        width: scaledSize.width,
                        height: scaledSize.height
                    )
                    ctx.cgContext.saveGState()
                    ctx.cgContext.translateBy(x: center.x, y: center.y)
                    ctx.cgContext.translateBy(x: -center.x, y: -center.y)
                    uiImage.draw(in: imageRect)
                    ctx.cgContext.restoreGState()
                }
            }
        }
        return image.pngData()
    }
    
    struct DraggableImageView: View {
        @Binding var item: ClothingItemPlacement
        var uiImage: UIImage
        @Binding var isSelected: Bool
        var onRemove: () -> Void

        @State private var dragOffset: CGSize = .zero
        @State private var currentScale: CGSize = CGSize(width: 1.0, height: 1.0)
        @GestureState private var isDetectingLongPress = false

        // Новый state для плавного масштабирования
        @State private var baseSize: CGSize? = nil

        var body: some View {
            ZStack {
                let baseSizeVal = item.size
                let halfWidth = baseSizeVal.width / 2
                let halfHeight = baseSizeVal.height / 2

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: baseSizeVal.width, height: baseSizeVal.height)
                    .offset(x: item.position.x + dragOffset.width, y: item.position.y + dragOffset.height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(isSelected ? Color.black : Color.clear, lineWidth: 1)
                            .frame(width: baseSizeVal.width, height: baseSizeVal.height)
                            .offset(x: item.position.x + dragOffset.width, y: item.position.y + dragOffset.height)
                    )
                    .onTapGesture {
                        isSelected = true
                    }
                    .gesture(
                        !isSelected ? nil : DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                item.position.x += value.translation.width
                                item.position.y += value.translation.height
                                dragOffset = .zero
                            }
                    )
                    // --- ПЛАВНОЕ масштабирование ---
                    .gesture(
                        !isSelected ? nil : MagnificationGesture()
                            .onChanged { scale in
                                // scale ≈ 1.0 обычно, больше — увеличение, меньше — уменьшение
                                if baseSize == nil {
                                    baseSize = item.size
                                }
                                let base = baseSize ?? item.size
                                // Можно снизить чувствительность, например, через pow(scale, 0.7)
                                let sensitivity: CGFloat = 0.6 // меньше = менее чувствительно
                                let effectiveScale = pow(scale, sensitivity)
                                let newWidth = max(40, base.width * effectiveScale)
                                let newHeight = max(40, base.height * effectiveScale)
                                item.size = CGSize(width: newWidth, height: newHeight)
                            }
                            .onEnded { _ in
                                baseSize = nil
                            }
                    )

                if isSelected {
                    let handleOffset: CGFloat = 10
                    // Remove button (top-left corner)
                    Button(action: { onRemove() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    }
                    .frame(width: 24, height: 24)
                    .offset(x: item.position.x + dragOffset.width - halfWidth - handleOffset,
                            y: item.position.y + dragOffset.height - halfHeight - handleOffset)

                    // Bottom-left
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 8, height: 8)
                        .offset(x: item.position.x + dragOffset.width - halfWidth, y: item.position.y + dragOffset.height + halfHeight)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let delta = -value.translation.width
                                    let newWidth = max(20, item.size.width + delta)
                                    let newHeight = max(20, item.size.height + delta)
                                    item.size = CGSize(width: newWidth, height: newHeight)
                                }
                        )

                    // Bottom-right
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 8, height: 8)
                        .offset(x: item.position.x + dragOffset.width + halfWidth, y: item.position.y + dragOffset.height + halfHeight)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let delta = value.translation.width
                                    let newWidth = max(20, item.size.width + delta)
                                    let newHeight = max(20, item.size.height + delta)
                                    item.size = CGSize(width: newWidth, height: newHeight)
                                }
                        )

                    // Top-left
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 8, height: 8)
                        .offset(x: item.position.x + dragOffset.width - halfWidth,
                                y: item.position.y + dragOffset.height - halfHeight)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let delta = -value.translation.width
                                    let newWidth = max(20, item.size.width + delta)
                                    let newHeight = max(20, item.size.height + delta)
                                    item.size = CGSize(width: newWidth, height: newHeight)
                                }
                        )

                    // Top-right
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 8, height: 8)
                        .offset(x: item.position.x + dragOffset.width + halfWidth,
                                y: item.position.y + dragOffset.height - halfHeight)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let delta = value.translation.width
                                    let newWidth = max(20, item.size.width + delta)
                                    let newHeight = max(20, item.size.height + delta)
                                    item.size = CGSize(width: newWidth, height: newHeight)
                                }
                        )
                }
            }
        }
    }
}

// Custom ShoppingSheet based on BottomSheet
struct ShoppingSheet<Content: View>: View {
    @Binding var isOpen: Bool
    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content

    @GestureState private var translation: CGFloat = 0

    init(isOpen: Binding<Bool>, maxHeight: CGFloat, minHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self._isOpen = isOpen
        self.maxHeight = maxHeight
        self.minHeight = minHeight
        self.content = content()
    }

    private var currentHeight: CGFloat {
        isOpen ? maxHeight : minHeight
    }

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Capsule()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 70, height: 6)
                    .padding(8)
                content
            }
            .frame(width: UIScreen.main.bounds.width, height: currentHeight, alignment: .top)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -4)
            .offset(y: translation > 0 ? translation : 0)
            .animation(.interactiveSpring(), value: isOpen)
            .gesture(
                DragGesture().updating($translation) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    if value.translation.height > 100 {
                        isOpen = false
                    }
                    if value.translation.height < -100 {
                        isOpen = true
                    }
                }
            )
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

