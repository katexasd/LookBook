//
//  LookBookApp.swift
//  LookBook
//
//  Created by Екатерина Збарская on 30.05.2025.
//
import SwiftUI

@main
struct LookBookApp: App {
    @StateObject private var clothingViewModel = ClothingViewModel()
    @StateObject private var lookViewModel = LookViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(clothingViewModel)
                .environmentObject(lookViewModel)
        }
    }
}
