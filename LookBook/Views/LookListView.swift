//
//  LookListView.swift
//  LookBook
//
//  Created by Екатерина Збарская on 29.07.2025.
//

import SwiftUI

struct LookListView: View {
    @EnvironmentObject var viewModel: LookViewModel
    @EnvironmentObject var clothingViewModel: ClothingViewModel
    @State private var selectedEvent: String? = nil
    @State private var showEditor = false
    @State private var showAddLook = false
    @State private var draftSnapshot: Data? = nil
    @State private var draftClothingItems: [ClothingItemPlacement] = []

    // Фильтр образов по событию
    var filteredLooks: [Look] {
        viewModel.looks.filter { selectedEvent == nil || $0.event == selectedEvent }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Горизонтальный скролл событий
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        let events = Array(Set(viewModel.looks.map { $0.event })).sorted()
                        ForEach(events, id: \.self) { event in
                            Button(action: {
                                withAnimation {
                                    selectedEvent = (selectedEvent == event) ? nil : event
                                }
                            }) {
                                Text(event)
                                    .font(.system(size: 15))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedEvent == event ? Color.gray.opacity(0.2) : Color.white)
                                    )
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .frame(height: 50)
                }

                // Сетка образов
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 0)
                        ],
                        spacing: 16
                    ) {
                        ForEach(filteredLooks) { look in
                            if let uiImage = UIImage(data: look.imageData) {
                                LookItemView(image: uiImage)
                            }
                        }
                    }
                    .padding(17)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("LookBook")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Создать образ вручную") {
                            draftSnapshot = nil
                            draftClothingItems = []
                            showEditor = true
                        }
                        Button("Сгенерировать образ") {}
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            ImageEditorView(initialClothingItems: []) { items, snapshot in
                draftClothingItems = items
                draftSnapshot = snapshot
                showEditor = false
            }
            .environmentObject(clothingViewModel)
        }
        .onChange(of: showEditor) { newValue in
            if newValue == false && draftSnapshot != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    showAddLook = true
                }
            }
        }
        .sheet(isPresented: $showAddLook) {
            AddLookView(imageData: draftSnapshot ?? Data(), clothingItems: draftClothingItems)
                .environmentObject(viewModel)
                .environmentObject(clothingViewModel)
        }
        .tint(.black)
    }
}

// Вынесенная ячейка образа
struct LookItemView: View {
    let image: UIImage

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: 110, height: 110)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
                .clipped()
                .cornerRadius(10)
        }
    }

}

struct LookListView_Previews: PreviewProvider {
    static var previews: some View {
        LookListView()
            .environmentObject(LookViewModel())
            .environmentObject(ClothingViewModel())
    }
}
