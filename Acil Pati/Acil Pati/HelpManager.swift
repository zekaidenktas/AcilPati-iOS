import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation
import Combine
import AudioToolbox

final class HelpManager: ObservableObject {
    
    static let shared = HelpManager()
    private init() {}
    
    private let database = Firestore.firestore()
    
    @Published var requests: [HelpRequest] = []
    
    // --- DİNLEME (GÜNCELLENDİ) ---
    func listenToRequests() {
        database.collection("requests")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents else { return }
                
                self.requests = documents.compactMap { document -> HelpRequest? in
                    try? document.data(as: HelpRequest.self)
                }
                
                // Ses çal
                if !self.requests.isEmpty {
                    AudioServicesPlaySystemSound(1007)
                }
                
                print("📣 Toplam İhbar: \(self.requests.count)")
            }
    }
    
    // --- ADRES ÇÖZME ---
    private func getAddressFromLatLon(latitude: Double, longitude: Double) async -> String {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        do {
            let placemarks = try await geoCoder.reverseGeocodeLocation(location)
            if let place = placemarks.first {
                let mahalle = place.subLocality ?? ""
                let cadde = place.thoroughfare ?? ""
                let numara = place.subThoroughfare ?? ""
                let ilce = place.locality ?? ""
                let sehir = place.administrativeArea ?? ""
                return "\(mahalle) \(cadde) No:\(numara), \(ilce)/\(sehir)"
            }
        } catch { }
        return "Adres Çözülemedi"
    }
    
    // --- GÖNDERME (MESAJ EKLENDİ) ---
    func sendHelpRequest(latitude: Double, longitude: Double, message: String) async throws {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let foundAddress = await getAddressFromLatLon(latitude: latitude, longitude: longitude)
        
        let newRequest = HelpRequest(
            id: UUID().uuidString,
            userId: currentUser.uid,
            userEmail: currentUser.email ?? "No Email",
            latitude: latitude,
            longitude: longitude,
            address: foundAddress,
            message: message, // 👈 Mesajı ekledik
            timestamp: Date()
        )
        
        try await database.collection("requests").document(newRequest.id).setData([
            "id": newRequest.id,
            "userId": newRequest.userId,
            "userEmail": newRequest.userEmail,
            "latitude": newRequest.latitude,
            "longitude": newRequest.longitude,
            "address": newRequest.address,
            "message": newRequest.message, // 👈 Veritabanına yazıyoruz
            "timestamp": newRequest.timestamp
        ])
        
        print("✅ İSTEK BAŞARILI! Mesaj: \(message)")
    }
}
