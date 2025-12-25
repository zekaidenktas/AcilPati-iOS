//
//  ContentView.swift
//  Acil Pati
//
//  Created by Zekai Denktaş on 3.11.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("girisYapildi") var girisYapildi = false
    
    var body : some View {
        if girisYapildi {
            MainView()
        } else {
            LoginView()
        }
    }
}


#Preview {
    ContentView()
}
