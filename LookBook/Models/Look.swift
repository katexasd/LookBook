//
//  Look.swift
//  LookBook
//
//  Created by Екатерина Збарская on 30.05.2025.
//
import Foundation
import SwiftUI

struct Look: Identifiable, Codable {
    var id = UUID()
    var imageData: Data
    var season: String
    var event: String
    var isPublic: Bool
    var clothingItems: [ClothingItemPlacement]
}

struct ClothingItemPlacement: Identifiable, Codable {
    var id: UUID
    var position: CGPoint
    var size: CGSize
}
