//
//  BerechnungsService.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import Foundation

class BerechnungsService {
    
    // MARK: - Erfolgswahrscheinlichkeit
    
    func berechneErfolgswahrscheinlichkeit(parameter: [String: Int]) -> Double {
        // Gewichtung der Parameter
        let gewichtungen: [String: Double] = [
            "Marktpotenzial": 1.5,
            "Teamkompetenz": 1.3,
            "Finanzplanung": 1.2,
            "Wettbewerbssituation": 1.1,
            "Innovationsgrad": 1.0,
            "Skalierbarkeit": 1.4,
            "Rechtliche Risiken": 0.9,
            "Technische Machbarkeit": 1.2
        ]
        
        var gewichteterWert = 0.0
        var maxGewichteterWert = 0.0
        
        for (key, value) in parameter {
            let gewichtung = gewichtungen[key] ?? 1.0
            gewichteterWert += Double(value) * gewichtung
            maxGewichteterWert += 10.0 * gewichtung
        }
        
        // Maximale Wahrscheinlichkeit: 90%
        return min(90.0, (gewichteterWert / maxGewichteterWert) * 100)
    }
    
    // MARK: - Marketingkosten
    
    func berechneMarketingkosten(branche: String, zielgruppe: String, reichweite: Int) -> Double {
        // Branchenspezifische Basisdaten
        let branchenKosten: [String: Double] = [
            "Immobilien": 1.2,
            "Technologie": 1.5,
            "Finanzen": 1.8,
            "Konsumgüter": 1.0,
            "Gesundheit": 1.3,
            "Energie": 1.4
        ]
        
        // Zielgruppenspezifische Multiplikatoren
        let zielgruppenMultiplikator: [String: Double] = [
            "Privatkunden": 1.0,
            "KMU": 1.2,
            "Großunternehmen": 1.5,
            "Investoren": 1.8,
            "Institutionen": 1.6
        ]
        
        let branchenMultiplikator = branchenKosten[branche] ?? 1.0
        let zielgruppenFaktor = zielgruppenMultiplikator[zielgruppe] ?? 1.0
        
        // Basiskosten pro Lead mit Skaleneffekten
        let basiskosten = 50.0
        let skaleneffekt = log10(Double(max(reichweite, 100)) / 100.0) * 0.7
        
        return basiskosten * branchenMultiplikator * zielgruppenFaktor / (1 + skaleneffekt)
    }
    
    // MARK: - Konversionsraten
    
    func berechneBruttoUndNettoKonversionsrate(
        branche: String,
        marketingKanal: String,
        zielgruppe: String
    ) -> (brutto: Double, netto: Double) {
        // Durchschnittliche Brutto-Konversionsraten nach Branche
        let bruttoRatenNachBranche: [String: Double] = [
            "Immobilien": 2.5,
            "Technologie": 3.2,
            "Finanzen": 1.8,
            "Konsumgüter": 3.5,
            "Gesundheit": 2.1,
            "Energie": 1.6
        ]
        
        // Kanalmultiplikatoren
        let kanalMultiplikatoren: [String: Double] = [
            "Email": 1.2,
            "Social Media": 0.9,
            "SEA": 1.1,
            "Content Marketing": 0.8,
            "Messen": 1.5,
            "Direktmarketing": 1.3
        ]
        
        // Zielgruppenfaktoren
        let zielgruppenFaktoren: [String: Double] = [
            "Privatkunden": 1.0,
            "KMU": 0.9,
            "Großunternehmen": 0.7,
            "Investoren": 0.6,
            "Institutionen": 0.5
        ]
        
        let basisRate = bruttoRatenNachBranche[branche] ?? 2.5
        let kanalFaktor = kanalMultiplikatoren[marketingKanal] ?? 1.0
        let zielgruppeFaktor = zielgruppenFaktoren[zielgruppe] ?? 1.0
        
        let bruttoRate = basisRate * kanalFaktor * zielgruppeFaktor
        // Nettokonversionsrate ist typischerweise 30-60% der Bruttokonversionsrate
        let nettoRate = bruttoRate * 0.45 * (0.9 + Double.random(in: 0...0.2))
        
        return (brutto: bruttoRate, netto: nettoRate)
    }
    
    // MARK: - Kundenreise-Kosten
    
    func berechneKundenreiseKosten(branche: String, phase: KundenPhase) -> (kosten: Double, konversionsrate: Double) {
        // Kosten pro Phase (in Euro)
        let phasenBasisKosten: [KundenPhase: Double] = [
            .leadGenerierung: 80.0,
            .qualifizierung: 120.0,
            .erstgespräch: 200.0,
            .letterOfIntent: 250.0,
            .finalesGespräch: 300.0,
            .abschluss: 350.0
        ]
        
        // Branchenmultiplikatoren
        let branchenMultiplikatoren: [String: Double] = [
            "Immobilien": 1.3,
            "Technologie": 1.1,
            "Finanzen": 1.4,
            "Konsumgüter": 0.9,
            "Gesundheit": 1.2,
            "Energie": 1.25
        ]
        
        // Typische Konversionsraten zwischen Phasen
        let phasenKonversionsraten: [KundenPhase: Double] = [
            .leadGenerierung: 25.0,
            .qualifizierung: 40.0,
            .erstgespräch: 50.0,
            .letterOfIntent: 70.0,
            .finalesGespräch: 85.0,
            .abschluss: 95.0
        ]
        
        let basisKosten = phasenBasisKosten[phase] ?? 100.0
        let branchenFaktor = branchenMultiplikatoren[branche] ?? 1.0
        let konversionsrate = phasenKonversionsraten[phase] ?? 50.0
        
        // Kosten berechnen mit leichter Zufallsvariation für Realismus
        let kosten = basisKosten * branchenFaktor * (0.95 + Double.random(in: 0...0.1))
        
        return (kosten: kosten, konversionsrate: konversionsrate)
    }
}
