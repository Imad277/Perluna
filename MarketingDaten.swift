//
//  MarketingDaten.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import Foundation

struct MarketingDaten: Codable, Identifiable {
    var id = UUID()
    var projektID: UUID
    var branche: String
    var zielgruppe: String
    var kanäle: [MarketingKanal]
    var gesamtbudget: Double
    
    // Berechnete Eigenschaften
    var kostenProKanal: [String: Double] {
        var ergebnis: [String: Double] = [:]
        for kanal in kanäle {
            ergebnis[kanal.name] = kanal.budgetAnteil * gesamtbudget
        }
        return ergebnis
    }
}

struct MarketingKanal: Codable, Identifiable {
    var id = UUID()
    var name: String
    var budgetAnteil: Double // Prozentsatz des Gesamtbudgets
    var geschätzteCPL: Double // Cost per Lead
    var geschätzteCPK: Double // Cost per Kunde
}
