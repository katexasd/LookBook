//
//  CareOverviewView.swift
//  LookBook
//
//  Created by Екатерина Збарская on 20.11.2025.
//

import SwiftUI

struct CareOverviewView: View {
    var careIcons: [String: String]
    var onClose: () -> Void
    var onEdit: () -> Void

    private let order: [String] = ["Стирка", "Отбеливание", "Сушка", "Глажение", "Проф. уход"]

    var body: some View {
        NavigationView {
            ScrollView {
                Spacer().frame(height: 12)
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(order, id: \.self) { section in
                        if let iconName = careIcons[section] {
                            HStack(alignment: .center) {
                                Image(iconName)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                Text(descriptionFor(section: section, iconName: iconName))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding(.horizontal)
                
                Button("Изменить") {
                    onEdit()
                }
                .foregroundColor(.blue)
                .padding(.top, 35)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("Уход за изделием")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { onClose() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }

    private func descriptionFor(section: String, iconName: String) -> String {
        switch section {
        case "Стирка":
            return ClothingViewModel.washing[iconName] ?? ""
        case "Отбеливание":
            return ClothingViewModel.bleaching[iconName] ?? ""
        case "Сушка":
            return ClothingViewModel.drying[iconName] ?? ""
        case "Глажение":
            return ClothingViewModel.ironing[iconName] ?? ""
        case "Проф. уход":
            return ClothingViewModel.professionalCare[iconName] ?? ""
        default:
            return ""
        }
    }
}

