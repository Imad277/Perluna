//
//  KonversionsAnalyseView.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI
import Charts

struct KonversionsAnalyseView: View {
    let projekt: Projekt
    
    @State private var bruttoKonversionsraten: [String: Double] = [
        "Email": 3.2,
        "Social Media": 2.7,
        "SEA": 4.1,
        "Content Marketing": 1.9,
        "Events": 5.5
    ]
    
    @State private var nettoKonversionsraten: [String: Double] = [
        "Email": 1.4,
        "Social Media": 1.1,
        "SEA": 1.8,
        "Content Marketing": 0.8,
        "Events": 2.7
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Konversionsraten-Analyse")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Analysieren Sie die Brutto- und Nettokonversionsraten verschiedener Marketingkanäle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Chart-Ansicht
                VStack(alignment: .leading, spacing: 12) {
                    Text("Brutto- vs. Nettokonversionsraten")
                        .font(.headline)
                    
                    Chart {
                        ForEach(Array(bruttoKonversionsraten.keys.sorted()), id: \.self) { kanal in
                            BarMark(
                                x: .value("Kanal", kanal),
                                y: .value("Brutto CVR", bruttoKonversionsraten[kanal] ?? 0)
                            )
                            .foregroundStyle(by: .value("Typ", "Brutto"))
                            
                            BarMark(
                                x: .value("Kanal", kanal),
                                y: .value("Netto CVR", nettoKonversionsraten[kanal] ?? 0)
                            )
                            .foregroundStyle(by: .value("Typ", "Netto"))
                        }
                    }
                    .chartForegroundStyleScale([
                        "Brutto": Color.blue,
                        "Netto": Color.green
                    ])
                    .chartLegend(position: .top)
                    .frame(height: 300)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                
                // Zusammenfassung
                VStack(alignment: .leading, spacing: 16) {
                    Text("Konversionsraten-Übersicht")
                        .font(.headline)
                    
                    ForEach(Array(bruttoKonversionsraten.keys.sorted()), id: \.self) { kanal in
                        HStack(alignment: .top) {
                            Text(kanal)
                                .font(.subheadline)
                                .frame(width: 140, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Brutto:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(width: 50, alignment: .leading)
                                    
                                    Text("\(bruttoKonversionsraten[kanal] ?? 0, specifier: "%.2f")%")
                                        .font(.subheadline)
                                    
                                    ProgressView(value: (bruttoKonversionsraten[kanal] ?? 0) / 10)
                                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                        .frame(width: 100)
                                }
                                
                                HStack {
                                    Text("Netto:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(width: 50, alignment: .leading)
                                    
                                    Text("\(nettoKonversionsraten[kanal] ?? 0, specifier: "%.2f")%")
                                        .font(.subheadline)
                                    
                                    ProgressView(value: (nettoKonversionsraten[kanal] ?? 0) / 10)
                                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                        .frame(width: 100)
                                }
                            }
                        }
                        .padding(.vertical, 4)
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
