//
//  LookViewModel.swift
//  LookBook
//
//  Created by Екатерина Збарская on 30.05.2025.
//
import Foundation
import SwiftUI

class LookViewModel: ObservableObject {
    @Published var looks: [Look] = []
    
    func addLook(_ look: Look) {
        looks.append(look)
    }
}
