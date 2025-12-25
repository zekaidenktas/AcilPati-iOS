//
//  Acil_PatiApp.swift
//  Acil Pati
//
//  Created by Zekai Denktaş on 3.11.2025.
//

import SwiftUI
import FirebaseCore


@main
struct Acil_PatiApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
