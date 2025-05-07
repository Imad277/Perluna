//
//  Projekt.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import Foundation

struct Projekt: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var beschreibung: String
    var branche: String
    var investitionsvolumen: Double
    var laufzeit: Int // in Monaten
    var renditeZiel: Double // in Prozent
    var risikoParameter: [String: Int] // Faktoren von 1-10
    var erstelltAm: Date
    var aktualisertAm: Date
    
    // Berechnete Eigenschaften
    var erfolgswahrscheinlichkeit: Double {
        // Berechnung basierend auf risikoParametern, max 90%
        let summe = risikoParameter.values.reduce(0, +)
        let maxWert = risikoParameter.count * 10
        return min(90.0, Double(summe) / Double(maxWert) * 100)
    }
    
    // Für Hashable-Konformität
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Projekt, rhs: Projekt) -> Bool {
        lhs.id == rhs.id
    }
}
