//
//  MainTabView.swift
//  LookBook
//
//  Created by Екатерина Збарская on 30.05.2025.
//
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 2 // 1 = "Вещи"

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Главная")
                .tabItem {
                    Label("Главная", systemImage: "house")
                }
                .tag(0)

            ClothingListView()
                .tabItem {
                    Label("Вещи", systemImage: "hanger")
                }
                .tag(1)

            LookListView()
                .tabItem {
                    Label("Образы", systemImage: "tshirt")
                }
                .tag(2)

            Text("Профиль")
                .tabItem {
                    Label("Профиль", systemImage: "person.crop.circle")
                }
                .tag(3)
        }
        .tint(.black)
    }
}
