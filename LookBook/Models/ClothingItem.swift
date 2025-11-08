//
//  ClothingItem.swift
//  LookBook
//
//  Created by Екатерина Збарская on 30.05.2025.
//
import Foundation
import SwiftUI

struct ClothingItem: Identifiable, Codable {
    var id = UUID()
    var imageData: Data
    var category: String
    var color: String
    var brand: String?
    var link: String?
    var careIcons: [String: String] = [:]
}
