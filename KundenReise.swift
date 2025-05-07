//
//  KundenReise.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import Foundation

enum KundenPhase: String, Codable, CaseIterable {
    case leadGenerierung = "Lead-Generierung"
    case qualifizierung = "Qualifizierung"
    case erstgespräch = "Erstgespräch"
    case letterOfIntent = "Letter of Intent"
    case finalesGespräch = "Finales Gespräch"
    case abschluss = "Abschluss"
}

struct KundenReise: Codable, Identifiable {
    var id = UUID()
    var projektID: UUID
    var phasenDaten: [KundenPhaseDaten]
    
    // Berechnete Eigenschaften
    var gesamtkosten: Double {
        phasenDaten.reduce(0) { $0 + $1.kosten }
    }
    
    var durchschnittlicheKonversionsrate: Double {
        let raten = phasenDaten.map { $0.konversionsrate }
        return raten.isEmpty ? 0 : raten.reduce(0, +) / Double(raten.count)
    }
}

struct KundenPhaseDaten: Codable, Identifiable {
    var id = UUID()
    var phase: KundenPhase
    var anzahlKontakte: Int
    var konversionsrate: Double // in Prozent
    var kosten: Double
    var durchschnittlicheDauer: Int // in Tagen
}
