//
//  ClothingViewModel.swift
//  LookBook
//
//  Created by Екатерина Збарская on 30.05.2025.
//
import Foundation
import SwiftUI

class ClothingViewModel: ObservableObject {
    @Published var items: [ClothingItem] = []
    
    // Словарь для стирки
    static let washing: [String: String] = [
        "Qwashable": "Нет информации о стирке",
        "washable": "Изделие можно стирать",
        "cannot_washed": "Изделие нельзя стирать",
        "softwash": "Мягкая стирка",
        "very_softwash": "Очень мягкая стирка",
        "wash30": "Стирка при 30 °C",
        "softwash30": "Мягкая стирка при 30 °C",
        "wash40": "Стирка при 40 °C",
        "softwash40": "Мягкая стирка при 40 °C",
        "wash50": "Стирка при 50 °C",
        "wash60": "Стирка при 60 °C",
        "wash95": "Стирка при 95 °C"
    ]

    // Словарь для отбеливания
    static let bleaching: [String: String] = [
        "Qwhitering": "Нет информации об отбеливания",
        "whitering": "Разрешен любой вид отбеливания",
        "dont_bleach": "Отбеливание запрещено",
        "bleach": "Отбеливание разрешено только с использованием средств без хлора",
        "CLbleach": "Разрешено отбеливание с использованием хлорсодержащих средств",
        "notCLbleach": "Отбеливание разрешено только с использованием средств без хлора"
    ]

    // Словарь для сушки
    static let drying: [String: String] = [
        "Qdrying": "Нет информации о сушке",
        "drying": "Изделие можно сушить",
        "dont_tumbledry": "Сушка в барабане запрещена",
        "verticaldrying": "Сушка в вертикальном положении",
        "horizontaldrying": "Сушка в горизонтальном положении",
        "shadedrying": "Сушка в тени",
        "dry_without_spinning": "Сушка без отжима",
        "lowtemperature_tumbledry": "Барабанная сушка при низкой температуре",
        "mediumtemperature_tumbledry": "Барабанная сушка при средней температуре",
        "hightemperature_tumbledry": "Барабанная сушка при высокой температуре"
    ]

    // Словарь для глажения
    static let ironing: [String: String] = [
        "Qironing": "Нет информации о глажении",
        "ironing": "Изделие можно гладить",
        "dontironing": "Изделие запрещено гладить",
        "steamironing": "Изделие можно отпаривать",
        "dontsteamironing": "Изделие запрещено отпаривать",
        "lowtemperature_iron": "Глажение при низкой температуре",
        "mediumtemperature_iron": "Глажение при средней температуре",
        "hightemperature_iron": "Глажение при высокой температуре"
    ]

    // Словарь для профессионального ухода
    static let professionalCare: [String: String] = [
        "Qprofessionalcleaning": "Нет информации о профессиональном уходе",
        "professionalcleaning": "Профессиональная чистка",
        "dontprofessionalcleaning": "Профессиональная чистка запрещена",
        "reducedcleaning": "Сокращенный цикл сухой чистки",
        "lowtemperature_cleaning": "Чистка при низкой температуре",
        "lowhumidity_cleaning": "Чистка при пониженной влажности",
        "cleaning_withoutsteaming": "Чистка без отпаривания",
        "Acleaning": "Химчистка всеми общепринятыми растворами",
        "Pcleaning": "Чистка на основе перхлорэтилена",
        "Wcleaning": "Аквачистка",
        "Fcleaning": "Чистка с использованием углеводорода",
        "Flcleaning": "Щадящая чистка с использованием углеводорода и трифлотрихлорметана",
        "Fllcleaning": "Деликатная чистка с использованием углеводорода и трифлотрихлорметана"
    ]
    
    func addItem(_ item: ClothingItem) {
        items.append(item)
    }
    
    init() {
        items = [
            ClothingItem(
                id: UUID(),
                imageData: UIImage(named: "sample1")?.jpegData(compressionQuality: 1.0) ?? Data(),
                category: "Топ",
                color: "Белый",
                brand: "Zara",
                link: nil,
                careIcons: [
                    "Стирка": "washable",
                    "Отбеливание": "whitering",
                    "Сушка": "drying",
                    "Глажение": "ironing",
                    "Проф. уход": "professionalcleaning"
                ]
            ),
            ClothingItem(
                id: UUID(),
                imageData: UIImage(named: "sample2")?.jpegData(compressionQuality: 1.0) ?? Data(),
                category: "Брюки",
                color: "Серый",
                brand: "H&M",
                link: nil,
                careIcons: [
                    "Стирка": "wash40",
                    "Отбеливание": "dont_bleach",
                    "Сушка": "horizontaldrying",
                    "Глажение": "lowtemperature_iron",
                    "Проф. уход": "Pcleaning"
                ]
            ),
            ClothingItem(
                id: UUID(),
                imageData: UIImage(named: "sample3")?.jpegData(compressionQuality: 1.0) ?? Data(),
                category: "Юбка",
                color: "Черный",
                brand: "Uniqlo",
                link: nil,
                careIcons: [
                    "Стирка": "wash60",
                    "Отбеливание": "bleach",
                    "Сушка": "shadedrying",
                    "Глажение": "steamironing",
                    "Проф. уход": "Wcleaning"
                ]
            ),
            ClothingItem(
                id: UUID(),
                imageData: UIImage(named: "sample4")?.jpegData(compressionQuality: 1.0) ?? Data(),
                category: "Топ",
                color: "Коричневый",
                brand: "Mango",
                link: nil,
                careIcons: [
                    "Стирка": "softwash30",
                    "Отбеливание": "CLbleach",
                    "Сушка": "dont_tumbledry",
                    "Глажение": "hightemperature_iron",
                    "Проф. уход": "Fcleaning"
                ]
            )
        ]
    }
}
