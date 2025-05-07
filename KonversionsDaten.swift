//
//  KonversionsDaten.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import Foundation

struct KonversionsDaten: Codable, Identifiable {
    var id = UUID()
    var projektID: UUID
    var marketingKanäle: [String]
    var bruttoKonversionsraten: [String: Double] // pro Kanal
    var nettoKonversionsraten: [String: Double] // pro Kanal
    
    // Berechnete Eigenschaften
    var durchschnittlicheBruttoKonversionsrate: Double {
        let summe = bruttoKonversionsraten.values.reduce(0, +)
        return bruttoKonversionsraten.isEmpty ? 0 : summe / Double(bruttoKonversionsraten.count)
    }
    
    var durchschnittlicheNettoKonversionsrate: Double {
        let summe = nettoKonversionsraten.values.reduce(0, +)
        return nettoKonversionsraten.isEmpty ? 0 : summe / Double(nettoKonversionsraten.count)
    }
}
