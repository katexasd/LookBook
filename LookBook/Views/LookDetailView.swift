//
//  LookDetailView.swift
//  LookBook
//
//  Created by Екатерина Збарская on 06.09.2025.
//

import SwiftUI

struct AddLookView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: LookViewModel

    @State private var showEditor = false
    @State private var showCloseConfirmation = false
    @State private var event: String = ""
    @State private var season: String = ""
    @State private var isPublic: Bool = false

    @State private var showAlert = false
    @State private var showDeleteConfirmation = false
    
    @State private var navigateToEditor = false

    var editItem: Look?
    @State private var imageData: Data
    @State private var clothingItems: [ClothingItemPlacement]

    init(
        editItem: Look? = nil,
        imageData: Data = Data(),
        clothingItems: [ClothingItemPlacement] = []
    ) {
        self.editItem = editItem
        _imageData = State(initialValue: imageData)
        _clothingItems = State(initialValue: clothingItems)
        _event = State(initialValue: editItem?.event ?? "")
        _season = State(initialValue: editItem?.season ?? "")
        _isPublic = State(initialValue: editItem?.isPublic ?? false)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {

                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            //.frame(width: 400, height: 570)
                            .clipped()
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)

                        Button(action: { showEditor = true }) {
                            Text("Редактировать образ")
                                .foregroundColor(.blue)
                                //.padding()
                                //.frame(maxWidth: .infinity)
                                //.background(Color.blue)
                                //.cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }

                    Group {
                        sectionRow(label: "Событие*", text: $event)
                        sectionRow(label: "Сезон*", text: $season)

                        HStack {
                            Text("Видимость в профиле")
                                .foregroundColor(.black)
                            Spacer()
                            Toggle("", isOn: $isPublic)
                                .labelsHidden()
                        }
                        .padding()
                        .frame(height: 50)
                        .background(Color(red: 0.93, green: 0.93, blue: 0.93))
                        .cornerRadius(8)
                    }

                    if editItem != nil {
                        Button("Удалить", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                        .padding(.top, 40)
                    }

                    Spacer().frame(height: 80)
                }
                .padding()
            }
        }
        .navigationTitle(editItem == nil ? "Добавить образ" : "Редактировать образ")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showCloseConfirmation = true }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    guard !event.isEmpty, !season.isEmpty else {
                        showAlert = true
                        return
                    }

                    let newLook = Look(
                        id: editItem?.id ?? UUID(),
                        imageData: imageData,
                        season: season,
                        event: event,
                        isPublic: isPublic,
                        clothingItems: clothingItems
                    )

                    if let index = viewModel.looks.firstIndex(where: { $0.id == newLook.id }) {
                        viewModel.looks[index] = newLook
                    } else {
                        viewModel.addLook(newLook)
                    }

                    dismiss() // Закрываем LookDetailView (и ImageEditorView, если был открыт)
                }) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.black)
                }
            }
        }
        .alert("Заполните обязательные поля: Событие и Сезон.", isPresented: $showAlert) {
            Button("ОК", role: .cancel) {}
        }
        .confirmationDialog("Удалить этот образ?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Удалить", role: .destructive) {
                if let id = editItem?.id {
                    viewModel.looks.removeAll { $0.id == id }
                    dismiss()
                }
            }
            Button("Отмена", role: .cancel) {}
        }
        .alert("Вы действительно хотите закрыть это окно? Изменения в образе не сохранятся.", isPresented: $showCloseConfirmation) {
            Button("Нет, остаться", role: .cancel) {}
            Button("Да, закрыть", role: .destructive) {
                dismiss()
            }
        }
        // Навигация на ImageEditorView
        .navigationDestination(isPresented: $showEditor) {
            ImageEditorView(
                initialClothingItems: clothingItems,
                isFromDetailView: true,
                onSave: { updatedItems, snapshot in
                    self.clothingItems = updatedItems
                    if let snapshot = snapshot { self.imageData = snapshot }
                    self.showEditor = false
                }
            )
        }
    }

    // Helper section
    @ViewBuilder
    private func sectionRow(label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.black)
            Spacer()
            TextField("", text: text)
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color.gray)
                .frame(minWidth: 100)
                .submitLabel(.done)
        }
        .padding()
        .frame(height: 50)
        .background(Color(red: 0.93, green: 0.93, blue: 0.93))
        .cornerRadius(8)
        .contentShape(Rectangle())
    }
}
