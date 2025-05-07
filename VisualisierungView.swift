//
//  VisualisierungView.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI
import Charts

struct VisualisierungView: View {
    let projekt: Projekt
    @State private var ausgewählterChartTyp = 0
    
    var body: some View {
        VStack {
            // Chart-Auswahl
            Picker("Chart-Typ", selection: $ausgewählterChartTyp) {
                Text("Erfolgswahrscheinlichkeit").tag(0)
                Text("Marketingkosten").tag(1)
                Text("Konversionsraten").tag(2)
                Text("Kundenreise").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Chart-Ansicht
            Group {
                switch ausgewählterChartTyp {
                case 0:
                    ErfolgswahrscheinlichkeitChart(projekt: projekt)
                case 1:
                    MarketingkostenChart(projekt: projekt)
                case 2:
                    KonversionsratenChart(projekt: projekt)
                case 3:
                    KundenreiseChart(projekt: projekt)
                default:
                    ErfolgswahrscheinlichkeitChart(projekt: projekt)
                }
            }
            .padding()
            .frame(height: 400)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            
            // Erläuterung zu den Charts
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Chart-Erläuterung")
                        .font(.headline)
                    
                    Text(erklärungFürChartTyp(ausgewählterChartTyp))
                        .font(.body)
                }
                .padding()
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(10)
            }
            .frame(maxHeight: 200)
        }
        .padding()
    }
    
    private func erklärungFürChartTyp(_ typ: Int) -> String {
        switch typ {
        case 0:
            return "Diese Darstellung zeigt die berechnete Erfolgswahrscheinlichkeit des Projekts basierend auf den verschiedenen Risikoparametern. Die maximale Erfolgswahrscheinlichkeit ist auf 90% begrenzt, um ein realistisches Risikoprofil zu gewährleisten."
        case 1:
            return "Hier sehen Sie die geschätzten Marketingkosten pro Kanal, basierend auf branchenüblichen Durchschnittswerten für die Branche '\(projekt.branche)' und das angegebene Investitionsvolumen."
        case 2:
            return "Diese Darstellung vergleicht die Brutto- und Nettokonversionsraten für verschiedene Marketingkanäle. Die Brutto-CVR bezieht sich auf alle generierten Leads, während die Netto-CVR die tatsächlichen Abschlüsse abbildet."
        case 3:
            return "Dieser Chart visualisiert die Kundenreise vom ersten Kontakt bis zum Abschluss. Er zeigt die Anzahl der Kontakte in jeder Phase sowie die entsprechenden Konversionsraten und Kosten."
        default:
            return ""
        }
    }
}

struct ErfolgswahrscheinlichkeitChart: View {
    let projekt: Projekt
    
    var body: some View {
        Chart {
            ForEach(Array(projekt.risikoParameter.keys.sorted()), id: \.self) { parameter in
                if let wert = projekt.risikoParameter[parameter] {
                    BarMark(
                        x: .value("Parameter", parameter),
                        y: .value("Wert", wert)
                    )
                    .foregroundStyle(by: .value("Parameter", parameter))
                }
            }
            
            RuleMark(
                y: .value("Durchschnitt", Double(projekt.risikoParameter.values.reduce(0, +)) / Double(max(1, projekt.risikoParameter.count)))
            )
            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
            .annotation(position: .top, alignment: .trailing) {
                Text("Durchschnitt")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .chartYScale(domain: 0...10)
        .frame(height: 300)
    }
}

struct MarketingkostenChart: View {
    let projekt: Projekt
    // Hier würden wir eigentlich die Marketingdaten des Projekts verwenden
    // Für Demo-Zwecke generieren wir Beispieldaten
    let marketingdaten: [String: Double] = [
        "Social Media": 12000,
        "SEA": 8000,
        "Content": 5000,
        "PR": 7000,
        "Events": 10000
    ]
    
    var body: some View {
        Chart {
            ForEach(Array(marketingdaten.keys.sorted()), id: \.self) { kanal in
                BarMark(
                    x: .value("Kanal", kanal),
                    y: .value("Kosten", marketingdaten[kanal] ?? 0)
                )
                .foregroundStyle(by: .value("Kanal", kanal))
            }
        }
        .frame(height: 300)
    }
}

struct KonversionsratenChart: View {
    let projekt: Projekt
    // Beispieldaten für die Demo
    let konversionsdaten: [(kanal: String, brutto: Double, netto: Double)] = [
        ("Email", 3.2, 1.4),
        ("Social", 2.7, 1.1),
        ("SEA", 4.1, 1.8),
        ("Content", 1.9, 0.8),
        ("Messen", 5.5, 2.7)
    ]
    
    var body: some View {
        Chart {
            ForEach(konversionsdaten, id: \.kanal) { daten in
                BarMark(
                    x: .value("Kanal", daten.kanal),
                    y: .value("Brutto CVR", daten.brutto)
                )
                .foregroundStyle(.blue)
                
                BarMark(
                    x: .value("Kanal", daten.kanal),
                    y: .value("Netto CVR", daten.netto)
                )
                .foregroundStyle(.green)
            }
        }
        .chartForegroundStyleScale([
            "Brutto CVR": .blue,
            "Netto CVR": .green
        ])
        .frame(height: 300)
    }
}

struct KundenreiseChart: View {
    let projekt: Projekt
    // Beispieldaten für die Demo
    let kundenreiseDaten: [(phase: String, anzahl: Int, konversionsrate: Double)] = [
        ("Lead", 1000, 25.0),
        ("Qualifizierung", 250, 40.0),
        ("Erstgespräch", 100, 50.0),
        ("LOI", 50, 70.0),
        ("Finales Gespräch", 35, 85.0),
        ("Abschluss", 30, 95.0)
    ]
    
    var body: some View {
        Chart {
            ForEach(kundenreiseDaten, id: \.phase) { daten in
                LineMark(
                    x: .value("Phase", daten.phase),
                    y: .value("Anzahl", daten.anzahl)
                )
                .interpolationMethod(.monotone)
                .symbol(.circle)
                .symbolSize(CGSize(width: 10, height: 10))
                .foregroundStyle(.blue)
                
                BarMark(
                    x: .value("Phase", daten.phase),
                    y: .value("Konversionsrate", daten.konversionsrate)
                )
                .foregroundStyle(.green.opacity(0.5))
            }
        }
        .chartForegroundStyleScale([
            "Anzahl": .blue,
            "Konversionsrate": .green
        ])
        .frame(height: 300)
    }
}
