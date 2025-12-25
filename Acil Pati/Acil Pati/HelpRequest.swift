//
//  HelpRequest.swift
//  Acil Pati
//
//  Created by Zekai Denktaş on 3.11.2025.
//

import Foundation
import FirebaseFirestore



struct HelpRequest: Codable, Identifiable, Hashable {
    var id: String
    var userId: String
    var userEmail: String
    var latitude: Double
    var longitude: Double
    var address: String
    var message: String
    var timestamp: Date
}

