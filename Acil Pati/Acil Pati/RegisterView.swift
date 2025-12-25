//
//  RegisterView.swift
//  Acil Pati
//
//  Created by Zekai Denktaş on 3.11.2025.
//

import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    
    // Ekranı kapatıp geri dönmek için
    @Environment(\.dismiss) var dismiss
    
    // Kullanıcının gireceği bilgiler
    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. ARKA PLAN (Tüm ekranı kaplar)
                Color.darkBackground
                    .ignoresSafeArea()
                
                // 2. ANA İÇERİK KUTUSU
                VStack(spacing: 25) {
                    
                    // --- LOGO VE BAŞLIK BÖLÜMÜ ---
                    VStack(spacing: 10) {
                        Image("AcilPatiLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        
                        Text("Acil Pati")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Kayıt Ol")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                        
                        Text("Hemen bir hesap oluştur.")
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                    
                    // --- KUTUCUKLAR BÖLÜMÜ ---
                    VStack(spacing: 15) {
                        CustomInputView(iconName: "envelope", placeholder: "E-posta", text: $email)
                            .foregroundColor(.white)
                        
                        CustomInputView(iconName: "lock", placeholder: "Şifre", text: $password, isSecure: true)
                            .foregroundColor(.white)
                        
                        // DİKKAT: Burada 'passwordConfirmation' kullandık
                        CustomInputView(iconName: "lock.shield", placeholder: "Şifre Tekrar", text: $passwordConfirmation, isSecure: true)
                            .foregroundColor(.white)
                    }
                    
                    // --- KAYIT OL BUTONU ---
                    Button {
                        Task {
                            // 1. Şifreler Eşleşiyor mu?
                            if password != passwordConfirmation {
                                alertMessage = "Hata: Şifreler uyuşmuyor!"
                                showAlert = true
                                return
                            }
                            
                            // 2. Kayıt İşlemi
                            do {
                                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                                print("Kayıt Başarılı: \(result.user.uid)")
                                // Başarılıysa ekranı kapat
                                dismiss()
                            } catch {
                                alertMessage = "Kayıt Başarısız: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                    } label: {
                        Text("Kayıt Ol")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.primaryBlue)
                            .cornerRadius(15)
                    }
                    
                    Spacer() // Geri dön butonunu en alta itmek için
                    
                    // --- GERİ DÖN BUTONU ---
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Giriş ekranına dön")
                        }
                        .foregroundColor(.blue)
                    }
                    
                } // Ana VStack Sonu
                .padding(25) // Kenarlardan boşluk bırak
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ekranı tam kapla
                
            } // ZStack Sonu
            
            .alert("Durum", isPresented: $showAlert) {
                Button("Tamam", role: .cancel) {}
                
            } message: {
                Text(alertMessage)
            }
            
        }
        .navigationBarBackButtonHidden(true) // Sistem geri butonunu gizle
    }
}

#Preview {
    RegisterView()
}
