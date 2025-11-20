//
//  ClothingListView.swift
//  LookBook
//
//  Created by Екатерина Збарская on 30.05.2025.
//
import SwiftUI

struct ClothingListView: View {
    @EnvironmentObject var viewModel: ClothingViewModel
    @State private var selectedCategory: String? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    /*Button(action: {
                        // Фильтр пока не активен
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title)
                            .foregroundColor(.black)
                    }*/

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            let categories = Array(Set(viewModel.items.map { $0.category })).sorted()
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    withAnimation {
                                        selectedCategory = (selectedCategory == category) ? nil : category
                                    }
                                }) {
                                    Text(category)
                                        .font(.system(size: 15))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedCategory == category ? Color.gray.opacity(0.2) : Color.white)
                                        )
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    .frame(height: 50)
                }

                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 0)
                        ],
                        spacing: 16
                    ) {
                        ForEach(viewModel.items.filter { selectedCategory == nil || $0.category == selectedCategory }) { item in
                            if let uiImage = UIImage(data: item.imageData) {
                                NavigationLink(destination: AddClothingItemView(editItem: item)) {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.white) // белый фон
                                            .frame(width: 110, height: 110)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 110, height: 110)
                                            .clipped()
                                            .cornerRadius(10)
                                    }
                                }
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
                    Button(action: {
                        // Фильтр пока не активен
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            //.font(.title)
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("LookBook")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddClothingItemView()) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .tint(.black)
    }
}

/*struct ClothingListView_Previews: PreviewProvider {
    static var previews: some View {
        ClothingListView()
            .environmentObject(ClothingViewModel())
    }
}*/
