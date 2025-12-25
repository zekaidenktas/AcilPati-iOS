//
//  LoginView.swift
//  Acil Pati
//
//  Created by Zekai Denktaş on 3.11.2025.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn


struct LoginView: View {
    @AppStorage("girisYapildi") var girisYapildi = false
    
    @State private var email = ""
    @State private var password = ""
    @State private var showResetAlert = false
    @State private var resetMessage = ""
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground
                    .ignoresSafeArea()
                
                VStack {
                    
                    VStack(spacing: 5) {
                        Image("AcilPatiLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        
                        Text ("Acil Pati")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 15) {
                        CustomInputView(iconName: "envelope", placeholder: "E-posta adresiniz", text: $email)
                            .foregroundColor(.white) // Yazılan yazı beyaz olsun
                        
                        CustomInputView(iconName: "lock", placeholder: "Şifreniz", text: $password, isSecure: true)
                            .foregroundColor(.white)
                       
                        HStack {
                            Spacer()
                            Button("Şifremi Unuttum?") {
                                if email.isEmpty {
                                    resetMessage = "Lütfen e-posta adresini yazın."
                                    showResetAlert = true
                                } else {
                                    Task {
                                        do {
                                            try await Auth.auth().sendPasswordReset(withEmail: email)
                                            resetMessage = "Sıfırlama Bağlantısı Gönderildi"
                                            showResetAlert = true
                                        } catch {
                                            resetMessage = "Hata: \(error.localizedDescription)"
                                            showResetAlert = true
                                        }
                                    }
                                }
                            }
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                        Button {
                            Task {
                                do {
                                    let result = try await Auth.auth().signIn(withEmail: email, password: password) // DOĞRU
                                    print("Giriş Başarılı: \(result.user.uid)")
                                    girisYapildi = true
                                } catch {
                                    print("Hata: \(error.localizedDescription)")
                                }
                                
                            }
                        } label: {
                            Text("Giriş Yap")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.primaryBlue)
                                .cornerRadius(15)
                        }
                        
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.white.opacity(0.2))
                            Text("veya")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.white.opacity(0.2))
                        }
                            .padding(.vertical, 10)
                        
                        
                        Button {
                            Task {
                                do {
                                    try await GoogleAuthManager.shared.signIn()
                                    girisYapildi = true
                                } catch {
                                    print("Google Hatası: \(error.localizedDescription)")
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Google ile Giriş Yap")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        Spacer()
                        
                        HStack {
                            
                            Text("Hesabınız yok mu?")
                                .foregroundColor(.gray)
                            
                            NavigationLink{
                                RegisterView()
                                    .navigationBarBackButtonHidden(true)
                            } label: {
                                Text("Kayıt Ol")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.primaryBlue)
                            }
                        }
                    }
                }
                .padding(25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                .alert("Şifre Sıfırlama", isPresented: $showResetAlert) {
                    Button("Tamam", role: .cancel) {}
                } message: {
                    Text(resetMessage)
                }
                
            }
        }
    }
    
    
}


#Preview {
    LoginView()
}

extension Color {
    static let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.12)
    static let inputGray = Color(red: 0.16, green: 0.16, blue: 0.18)
    static let primaryBlue = Color(red: 0.2, green: 0.5, blue: 1.0)
}

struct CustomInputView: View {
    var iconName: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    @State private var showPassword = false
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            if !isSecure || showPassword {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .keyboardType(iconName == "envelope" ? .emailAddress : .default)
            } else {
                SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
            }
            
            if isSecure  {
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                        
                }
            }
        }
        .padding()
        .background(Color.inputGray)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3),lineWidth: 1)
        )
        
    }
}
