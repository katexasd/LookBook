import SwiftUI
import PhotosUI

let defaultCareIcons: [String: String] = [
    "Стирка": "Qwashable",
    "Отбеливание": "Qwhitering",
    "Сушка": "Qdrying",
    "Глажение": "Qironing",
    "Проф. уход": "Qprofessionalcleaning"
]

struct AddClothingItemView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: ClothingViewModel

    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    
    @State private var showPhotoPicker = false

    @State private var name: String = ""
    @State private var category: String = ""
    @State private var color: String = ""
    @State private var brand: String = ""
    @State private var link: String = ""

    @State private var showAlert = false
    @State private var showDeleteConfirmation = false
    
    @State private var showCareSelection = false
    @State private var tempCareIcons: [String: String] = [:]

    @State private var showCareOverview = false
    
    @FocusState private var focusedEntryID: UUID?
    
    
    var editItem: ClothingItem?

    init(editItem: ClothingItem? = nil) {
        self.editItem = editItem
        _category = State(initialValue: editItem?.category ?? "")
        _color = State(initialValue: editItem?.color ?? "")
        _brand = State(initialValue: editItem?.brand ?? "")
        _link = State(initialValue: editItem?.link ?? "")
        _imageData = State(initialValue: editItem?.imageData)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: UIScreen.main.bounds.width - 32)
                            .cornerRadius(10)

                        if let data = imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width - 32)
                                .clipped()
                                .cornerRadius(10)
                        } else {
                            Text("Добавить фото")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showPhotoPicker = true
                    }
                    
                    .photosPicker(isPresented: $showPhotoPicker, selection: $selectedImage, matching: .images)
                    .onChange(of: selectedImage) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                imageData = data
                            }
                        }
                    }
                    
                    if imageData != nil {
                        Button("Изменить фото") {
                            showPhotoPicker = true
                        }
                        .foregroundColor(.blue)
                    }

                    Group {
                        sectionRow(label: "Категория*", text: $category)
                        sectionRow(label: "Цвет*", text: $color)
                        sectionRow(label: "Бренд", text: $brand)
                        sectionRow(label: "Ссылка", text: $link)
                        
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                                .frame(height: 100)
                                .overlay(
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Уход")
                                            .foregroundColor(.black)
                                        HStack {
                                            Spacer()
                                            HStack(spacing: 18) {
                                                let careIconsToShow: [String: String] = {
                                                    if !tempCareIcons.isEmpty {
                                                        return tempCareIcons
                                                    } else if let careIcons = editItem?.careIcons, !careIcons.isEmpty {
                                                        return careIcons
                                                    } else {
                                                        return defaultCareIcons
                                                    }
                                                }()
                                                let order: [String] = ["Стирка", "Отбеливание", "Сушка", "Глажение", "Проф. уход"]
                                                ForEach(order, id: \.self) { key in
                                                    if let iconName = careIconsToShow[key] {
                                                        Image(iconName)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 45, height: 45)
                                                    }
                                                }
                                            }
                                            Spacer()
                                        }
                                    }
                                    .padding(),
                                    alignment: .topLeading
                                )
                                .onTapGesture {
                                    if editItem?.careIcons.isEmpty ?? true {
                                        tempCareIcons = [:]
                                        showCareSelection = true
                                    } else {
                                        showCareOverview = true
                                    }
                                }
                        }
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
        .navigationTitle(editItem == nil ? "Добавить вещь" : "Редактировать вещь")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    guard !category.isEmpty, !color.isEmpty, let imageData = imageData else {
                        showAlert = true
                        return
                    }

                    let newItem = ClothingItem(
                        id: editItem?.id ?? UUID(),
                        imageData: imageData,
                        category: category,
                        color: color,
                        brand: brand.isEmpty ? nil : brand,
                        link: link.isEmpty ? nil : link,
                        careIcons: !tempCareIcons.isEmpty ? tempCareIcons : (editItem?.careIcons ?? [:])
                    )

                    if let index = viewModel.items.firstIndex(where: { $0.id == newItem.id }) {
                        viewModel.items[index] = newItem
                    } else {
                        viewModel.addItem(newItem)
                    }

                    dismiss()
                }) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.black)
                }
            }
        }
        .alert("Заполните обязательные поля: Категория, Цвет и выберите фото.", isPresented: $showAlert) {
            Button("ОК", role: .cancel) {}
        }
        .confirmationDialog("Удалить эту вещь?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Удалить", role: .destructive) {
                if let id = editItem?.id {
                    viewModel.items.removeAll { $0.id == id }
                    dismiss()
                }
            }
            Button("Отмена", role: .cancel) {}
        }
        .sheet(isPresented: $showCareSelection) {
            CareSelectionView(
                tempCareIcons: $tempCareIcons,
                onCancel: { showCareSelection = false },
                onSave: {
                    var finalIcons = tempCareIcons
                    for (section, defaultIcon) in defaultCareIcons {
                        if finalIcons[section] == nil {
                            finalIcons[section] = defaultIcon
                        }
                    }
                    if let id = editItem?.id,
                       let index = viewModel.items.firstIndex(where: { $0.id == id }) {
                        viewModel.items[index].careIcons = finalIcons
                    }
                    tempCareIcons = finalIcons
                    showCareSelection = false
                }
            )
        }
        
        .sheet(isPresented: $showCareOverview) {
            CareOverviewView(
                careIcons: editItem?.careIcons ?? [:],
                onClose: { showCareOverview = false },
                onEdit: {
                    showCareOverview = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let careIcons = editItem?.careIcons {
                            tempCareIcons = careIcons
                        }
                        showCareSelection = true
                    }
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
    
    @ViewBuilder
    private func sectionRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.black)
            Spacer()
            content()
                .frame(minWidth: 100)
        }
        .padding()
        .frame(height: 50)
        .background(Color(red: 0.93, green: 0.93, blue: 0.93))
        .cornerRadius(8)
        .contentShape(Rectangle())
    }
}

struct AddClothingItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddClothingItemView()
            .environmentObject(ClothingViewModel())
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

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

struct RadioButton: View {
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Circle()
            .stroke(Color.black, lineWidth: 2)
            .frame(width: 20, height: 20)
            .overlay(
                Circle()
                    .fill(isSelected ? Color.black : Color.clear)
                    .frame(width: 12, height: 12)
            )
            .onTapGesture { action() }
    }
}

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
