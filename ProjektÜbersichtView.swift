//
//  ProjektÜbersichtView.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI

struct ProjektÜbersichtView: View {
    let projekt: Projekt
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Projektkopf
                HStack {
                    VStack(alignment: .leading) {
                        Text(projekt.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(projekt.branche)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Investitionsvolumen")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("€\(String(format: "%.2f", projekt.investitionsvolumen))")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                
                // Kernkennzahlen
                HStack(spacing: 20) {
                    KennzahlKarteView(
                        titel: "Erfolgswahrscheinlichkeit",
                        wert: "\(Int(projekt.erfolgswahrscheinlichkeit))%",
                        symbol: "checkmark.circle",
                        farbe: .green
                    )
                    
                    KennzahlKarteView(
                        titel: "Laufzeit",
                        wert: "\(projekt.laufzeit) Monate",
                        symbol: "calendar",
                        farbe: .blue
                    )
                    
                    KennzahlKarteView(
                        titel: "Rendite-Ziel",
                        wert: String(format: "%.1f%%", projekt.renditeZiel),
                        symbol: "arrow.up.right",
                        farbe: .orange
                    )
                }
                
                // Beschreibung
                VStack(alignment: .leading, spacing: 10) {
                    Text("Projektbeschreibung")
                        .font(.headline)
                    
                    Text(projekt.beschreibung)
                        .font(.body)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                
                // Risikobewertung
                VStack(alignment: .leading, spacing: 10) {
                    Text("Risikobewertung")
                        .font(.headline)
                    
                    ForEach(Array(projekt.risikoParameter.keys.sorted()), id: \.self) { key in
                        if let wert = projekt.risikoParameter[key] {
                            HStack {
                                Text(key)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                HStack(spacing: 2) {
                                    ForEach(1...10, id: \.self) { i in
                                        RoundedRectangle(cornerRadius: 2)
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(i <= wert ? .blue : Color.secondary.opacity(0.3))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct KennzahlKarteView: View {
    let titel: String
    let wert: String
    let symbol: String
    let farbe: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundColor(farbe)
                
                Text(titel)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Text(wert)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}
