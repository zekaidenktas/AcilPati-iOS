import SwiftUI
import MapKit
import FirebaseAuth
import GoogleSignIn

struct MainView: View {
    @AppStorage("girisYapildi") var girisYapildi = false
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var helpManager = HelpManager.shared
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedRequest: HelpRequest?
    
    // YENİ: Mesaj ve Tarih Değişkenleri
    @State private var showInputSheet = false
    @State private var userMessage = ""
    @State private var selectedDate = Date()
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    // Yönetici Kontrolü
    var isAdmin: Bool {
        let adminEmails = ["zekaidenktas@gmail.com"]
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return false }
        return adminEmails.contains(currentUserEmail)
    }
    
    var body: some View {
        ZStack {
            // 1. KATMAN: HARİTA
            Map(position: $cameraPosition, selection: $selectedRequest) {
                UserAnnotation() // Mavi Nokta
                
                if isAdmin {
                    // Tarihe Göre Filtrele ve Göster
                    ForEach(helpManager.requests.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate) }) { request in
                        Marker(request.address, coordinate: CLLocationCoordinate2D(latitude: request.latitude, longitude: request.longitude))
                            .tint(.red)
                            .tag(request)
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                if isAdmin { helpManager.listenToRequests() }
            }
            
            // 2. KATMAN: BUTONLAR
            VStack {
                // --- ÜST KISIM ---
                HStack {
                    Button {
                        do {
                            try Auth.auth().signOut()
                            GIDSignIn.sharedInstance.signOut()
                            girisYapildi = false
                        } catch {
                            print("Çıkış Hatası: \(error.localizedDescription)")
                        }
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Çıkış")
                        }
                        .padding(10)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                        .foregroundColor(.blue)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    // YÖNETİCİ TARİH SEÇİCİ
                    if isAdmin {
                        HStack {
                            Image(systemName: "calendar")
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .labelsHidden()
                                .colorScheme(.light)
                                .foregroundColor(.blue)
                        }
                        .padding(8)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                        .padding(.trailing)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.top, 10)
                
                Spacer()
                
                // --- ALT KISIM ---
                if !isAdmin {
                    // YARDIM BUTONU (Mesaj Penceresini Açar)
                    Button {
                        if locationManager.userLocation != nil {
                            userMessage = ""
                            showInputSheet = true // Pencereyi aç
                        } else {
                            print("Konum Yok!")
                        }
                    } label: {
                        ZStack {
                            Circle().fill(Color.red.opacity(0.9)).frame(width: 150, height: 150)
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            Text("Yardım\nÇağır").font(.title).bold().foregroundColor(.white).multilineTextAlignment(.center)
                        }
                    }
                    .padding(.bottom, 20)
                } else {
                    // YÖNETİCİ BİLGİSİ
                    HStack {
                        Image(systemName: "shield.check.fill")
                            .foregroundColor(.blue)
                        Text("Saha Kontrol Ekranı")
                            .font(.headline)
                    }
                    
                    .padding(15)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                    .padding(.bottom, 20)
                    .foregroundColor(.blue)
                }
            }
        }
        // MESAJ GİRİŞ PENCERESİ
        .sheet(isPresented: $showInputSheet) {
            VStack(spacing: 20) {
                Text("Durumu Açıklayın").font(.title2).bold().padding(.top)
                TextField("Örn: Yaralı kedi, ağaçta mahsur...", text: $userMessage)
                    .padding().background(Color.gray.opacity(0.1)).cornerRadius(10).padding(.horizontal)
                
                Button("Gönder") {
                    if let location = locationManager.userLocation {
                        Task {
                            do {
                                try await HelpManager.shared.sendHelpRequest(
                                    latitude: location.latitude,
                                    longitude: location.longitude,
                                    message: userMessage
                                )
                                showInputSheet = false
                                alertMessage = "✅ İletildi!"
                                showAlert = true
                            } catch {
                                alertMessage = "Hata: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent).padding()
                Spacer()
            }
            .presentationDetents([.medium])
        }
        // İĞNE DETAY PENCERESİ
        .sheet(item: $selectedRequest) { request in
            VStack(spacing: 15) {
                Text("🚑 Yardım Talebi").font(.title).bold()
                Text("📝 \"\(request.message)\"").font(.headline).padding().background(Color.yellow.opacity(0.2)).cornerRadius(8)
                Text("📍 \(request.address)").multilineTextAlignment(.center)
                Text("⏰ \(request.timestamp.formatted())").font(.caption).foregroundColor(.gray)
            }
            .padding().presentationDetents([.medium])
        }
        .alert("Bilgi", isPresented: $showAlert) { Button("Tamam") {} } message: { Text(alertMessage) }
        .onChange(of: locationManager.userLocation) { oldValue, newLocation in
            if let location = newLocation {
                withAnimation {
                    cameraPosition = .region(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)))
                }
            }
        }
    }
}

#Preview {
    MainView()
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
