//
//  CareSelectionView.swift
//  LookBook
//
//  Created by Екатерина Збарская on 20.11.2025.
//

import SwiftUI

struct CareSelectionView: View {
    @Binding var tempCareIcons: [String: String]
    var onCancel: () -> Void
    var onSave: () -> Void

    @State private var selectedSection: String = "Стирка"
    @Namespace private var animation

    private let sections: [(icon: String, title: String)] = [
        ("washable", "Стирка"),
        ("whitering", "Отбеливание"),
        ("drying", "Сушка"),
        ("ironing", "Глажение"),
        ("professionalcleaning", "Проф. уход")
    ]

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 25) {
                        ForEach(sections, id: \.title) { section in
                            sectionButton(icon: section.icon, title: section.title)
                        }
                    }
                    .padding()
                }

                TabView(selection: $selectedSection) {
                    ForEach(sections, id: \.title) { section in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(optionsForSection(section.title), id: \.key) { key, value in
                                    HStack {
                                        Image(key)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                        Text(value)
                                        Spacer()
                                        RadioButton(isSelected: tempCareIcons[section.title] == key) {
                                            tempCareIcons[section.title] = key
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                        .tag(section.title)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedSection)
            }
            .navigationTitle("Уход за изделием")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { onCancel() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { onSave() }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }

    private func sectionButton(icon: String, title: String) -> some View {
        let isSelected = selectedSection == title
        return Group {
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .matchedGeometryEffect(id: "sectionHighlight", in: animation)
                    .overlay(
                        VStack {
                            Image(icon)
                                .resizable()
                                .frame(width: 45, height: 45)
                            Text(title)
                                .font(.caption)
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.vertical, 4)
                    )
                    .frame(width: 90, height: 80)
            } else {
                VStack {
                    Image(icon)
                        .resizable()
                        .frame(width: 45, height: 45)
                    Text(title)
                        .font(.caption)
                        .lineLimit(1)
                }
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: 90, height: 80)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                selectedSection = title
            }
        }
    }

    private func optionsForSection(_ section: String) -> [(key: String, value: String)] {
        switch section {
        case "Стирка":
            return Array(ClothingViewModel.washing)
        case "Отбеливание":
            return Array(ClothingViewModel.bleaching)
        case "Сушка":
            return Array(ClothingViewModel.drying)
        case "Глажение":
            return Array(ClothingViewModel.ironing)
        case "Проф. уход":
            return Array(ClothingViewModel.professionalCare)
        default:
            return []
        }
    }
}

struct CareSelectionView_Previews: PreviewProvider {
    @State static var tempIcons: [String: String] = [:]

    static var previews: some View {
        CareSelectionView(
            tempCareIcons: $tempIcons,
            onCancel: {},
            onSave: {}
        )
    }
}
