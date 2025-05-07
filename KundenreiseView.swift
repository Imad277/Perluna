//
//  KundenreiseView.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

//
// KundenreiseView.swift
// FundingForce_01
//
// Created by Imad Labbadi on 05.05.25.
//

//
// KundenreiseView.swift
// FundingForce_01
//
// Created by Imad Labbadi on 05.05.25.
//

import SwiftUI
import Charts

struct KundenreiseView: View {
    let projekt: Projekt
    @EnvironmentObject var projektManager: ProjektManager
    
    @State private var kundenPhasen: [KundenPhaseDaten] = []
    @State private var zeigeBearbeitungsDialog = false
    @State private var ausgewähltePhasenDaten: KundenPhaseDaten?
    @State private var ausgewählterTabIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Kundenreise-Analyse")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Analysieren Sie die Customer Journey von der Lead-Generierung bis zum Abschluss")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Tabs
                Picker("Ansicht", selection: $ausgewählterTabIndex) {
                    Text("Übersicht").tag(0)
                    Text("Kosten").tag(1)
                    Text("Konversion").tag(2)
                    Text("Zeitverlauf").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom)
                
                // Tab-Inhalt
                Group {
                    switch ausgewählterTabIndex {
                    case 0:
                        KundenreiseÜbersichtView(phasen: kundenPhasen, onPhasenSelect: { phase in
                            ausgewähltePhasenDaten = phase
                            zeigeBearbeitungsDialog = true
                        })
                    case 1:
                        KundenreiseKostenView(phasen: kundenPhasen)
                    case 2:
                        KundenreiseKonversionView(phasen: kundenPhasen)
                    case 3:
                        KundenreiseZeitverlaufView(phasen: kundenPhasen)
                    default:
                        KundenreiseÜbersichtView(phasen: kundenPhasen, onPhasenSelect: { phase in
                            ausgewähltePhasenDaten = phase
                            zeigeBearbeitungsDialog = true
                        })
                    }
                }
                
                // Zusammenfassung
                VStack(alignment: .leading, spacing: 16) {
                    Text("Zusammenfassung")
                        .font(.headline)
                    
                    let gesamtkosten = kundenPhasen.reduce(0) { $0 + $1.kosten }
                    let gesamtdauer = kundenPhasen.reduce(0) { $0 + $1.durchschnittlicheDauer }
                    let anfangsKontakte = kundenPhasen.first?.anzahlKontakte ?? 0
                    let endKontakte = kundenPhasen.last?.anzahlKontakte ?? 0
                    let gesamtkonversion = anfangsKontakte > 0 ? Double(endKontakte) / Double(anfangsKontakte) * 100 : 0
                    
                    HStack {
                        InfoKarteView(
                            titel: "Gesamtkosten",
                            wert: "€\(String(format: "%.2f", gesamtkosten))",
                            untertitel: "pro Abschluss",
                            symbol: "eurosign.circle.fill",
                            farbe: .blue
                        )
                        
                        InfoKarteView(
                            titel: "Dauer",
                            wert: "\(gesamtdauer) Tage",
                            untertitel: "durchschnittlich",
                            symbol: "clock.fill",
                            farbe: .orange
                        )
                        
                        InfoKarteView(
                            titel: "Gesamtkonversion",
                            wert: "\(String(format: "%.2f", gesamtkonversion))%",
                            untertitel: "Lead zu Abschluss",
                            symbol: "arrow.triangle.2.circlepath",
                            farbe: .green
                        )
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            erstelleKundenphasen()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("MarketingDatenGeändert"))) { _ in
            // Diese Funktion wird aufgerufen, wenn sich die Marketingdaten ändern
            erstelleKundenphasen()
        }
        .onChange(of: projekt) { _ in
            erstelleKundenphasen()
        }
        .sheet(isPresented: $zeigeBearbeitungsDialog) {
            if let phasenDaten = ausgewähltePhasenDaten {
                KundenPhaseBearbeitenView(
                    phasenDaten: phasenDaten,
                    onSave: { aktualiserteDaten in
                        if let index = kundenPhasen.firstIndex(where: { $0.id == aktualiserteDaten.id }) {
                            kundenPhasen[index] = aktualiserteDaten
                            speichereÄnderungen()
                        }
                    }
                )
            }
        }
    }
    
    private func erstelleKundenphasen() {
        let berechnungsService = BerechnungsService()
        var phasen: [KundenPhaseDaten] = []
        
        // Berechne die Gesamtzahl der generierten Leads basierend auf dem Investitionsvolumen
        // Je höher das Investitionsvolumen, desto mehr Leads können generiert werden
        let geschätztesMarketingbudget = max(projekt.investitionsvolumen * 0.05, 50000) // 5% des Investitionsvolumens
        let durchschnittlicheCPL = 50.0 // Durchschnittliche Kosten pro Lead
        let geschätzteLeads = geschätztesMarketingbudget / durchschnittlicheCPL
        
        // Werte für die Kundenreise-Phasen basierend auf den Screenshots
        var anzahlKontakte = 5000 // Startanzahl der Leads
        
        // Für jede Phase der Kundenreise
        for phase in KundenPhase.allCases {
            let (basisKosten, _) = berechnungsService.berechneKundenreiseKosten(branche: projekt.branche, phase: phase)
            
            // Anpassung der Werte basierend auf dem Screenshot
            var konversionsrate: Double = 0.0
            var kosten: Double = 0.0
            var dauer: Int = 7
            
            switch phase {
            case .leadGenerierung:
                konversionsrate = 41.7
                kosten = 256.83
                dauer = 7
                anzahlKontakte = 5000
            case .qualifizierung:
                konversionsrate = 43.5
                kosten = 373.00
                dauer = 14
                anzahlKontakte = 2083
            case .erstgespräch:
                konversionsrate = 83.3
                kosten = 643.61
                dauer = 7
                anzahlKontakte = 1388
            case .letterOfIntent:
                konversionsrate = 99.0
                kosten = 773.51
                dauer = 14
                anzahlKontakte = 1156
            case .finalesGespräch:
                konversionsrate = 99.0
                kosten = 1016.87
                dauer = 7
                anzahlKontakte = 1144
            case .abschluss:
                konversionsrate = 99.0
                kosten = 1090.82
                dauer = 3
                anzahlKontakte = 1132
            }
            
            // Skalieren der Kosten basierend auf dem Marketingbudget
            let budgetFaktor = geschätztesMarketingbudget / 100000
            kosten = basisKosten * budgetFaktor
            
            phasen.append(KundenPhaseDaten(
                phase: phase,
                anzahlKontakte: anzahlKontakte,
                konversionsrate: konversionsrate,
                kosten: kosten,
                durchschnittlicheDauer: dauer
            ))
        }
        
        kundenPhasen = phasen
    }
    
    private func speichereÄnderungen() {
        // Erstelle eine KundenReise-Instanz
        let kundenReise = KundenReise(
            projektID: projekt.id,
            phasenDaten: kundenPhasen
        )
        
        // Hier würden wir normalerweise diese Daten im ProjektManager speichern
        // Im Moment aktualisieren wir nur das Projekt selbst
        var aktualisierteProjekt = projekt
        // Hier könnten wir Projekt-Eigenschaften aktualisieren, wenn nötig
        projektManager.aktualisiereProjekt(projekt: aktualisierteProjekt)
        
        // Benachrichtigung senden, damit andere Views wissen, dass sich die Kundenreise geändert hat
        NotificationCenter.default.post(name: NSNotification.Name("KundenreiseDatenGeändert"), object: nil)
    }
}

struct KundenreiseÜbersichtView: View {
    let phasen: [KundenPhaseDaten]
    let onPhasenSelect: (KundenPhaseDaten) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Visualisierung der Phasen mit blauen Kreisen und Verbindungslinien
            HStack(spacing: 0) {
                ForEach(phasen) { phase in
                    VStack(spacing: 12) {
                        Text(phase.phase.rawValue)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 70, height: 70)
                            
                            Text("\(phase.anzahlKontakte)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            onPhasenSelect(phase)
                        }
                        
                        Text("\(Int(phase.konversionsrate))%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        Text("Konversionsrate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            .overlay(
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 2)
                    .offset(y: -45),
                alignment: .center
            )
            
            // Tabelle
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Phase")
                        .fontWeight(.medium)
                        .frame(width: 150, alignment: .leading)
                    
                    Spacer()
                    
                    Text("Kontakte")
                        .fontWeight(.medium)
                        .frame(width: 100, alignment: .trailing)
                    
                    Text("Konversion")
                        .fontWeight(.medium)
                        .frame(width: 100, alignment: .trailing)
                    
                    Text("Kosten")
                        .fontWeight(.medium)
                        .frame(width: 100, alignment: .trailing)
                    
                    Text("Dauer")
                        .fontWeight(.medium)
                        .frame(width: 100, alignment: .trailing)
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.secondary.opacity(0.2))
                
                // Zeilen
                ForEach(phasen) { phase in
                    VStack(spacing: 0) {
                        HStack {
                            Text(phase.phase.rawValue)
                                .font(.subheadline)
                                .frame(width: 150, alignment: .leading)
                            
                            Spacer()
                            
                            Text("\(phase.anzahlKontakte)")
                                .font(.subheadline)
                                .frame(width: 100, alignment: .trailing)
                            
                            Text("\(String(format: "%.1f", phase.konversionsrate))%")
                                .font(.subheadline)
                                .frame(width: 100, alignment: .trailing)
                            
                            Text("€\(String(format: "%.2f", phase.kosten))")
                                .font(.subheadline)
                                .frame(width: 100, alignment: .trailing)
                            
                            Text("\(phase.durchschnittlicheDauer) Tage")
                                .font(.subheadline)
                                .frame(width: 100, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color(NSColor.windowBackgroundColor))
                        
                        Divider()
                    }
                    .onTapGesture {
                        onPhasenSelect(phase)
                    }
                }
            }
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct KundenreiseKostenView: View {
    let phasen: [KundenPhaseDaten]
    
    var body: some View {
        VStack(spacing: 20) {
            Chart {
                ForEach(phasen) { phase in
                    BarMark(
                        x: .value("Phase", phase.phase.rawValue),
                        y: .value("Kosten", phase.kosten)
                    )
                    .foregroundStyle(by: .value("Phase", phase.phase.rawValue))
                }
                
                RuleMark(
                    y: .value("Durchschnitt", phasen.map { $0.kosten }.reduce(0, +) / Double(max(1, phasen.count)))
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .annotation(position: .top, alignment: .trailing) {
                    Text("Durchschnitt")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 300)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel {
                        if let string = value.as(String.self) {
                            Text(string)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let value = value.as(Double.self) {
                            Text("€\(String(format: "%.0f", value))")
                                .font(.caption)
                        }
                    }
                }
            }
            
            // Kostentabelle
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Phase")
                        .fontWeight(.medium)
                        .frame(width: 150, alignment: .leading)
                    
                    Spacer()
                    
                    Text("Kosten/Kontakt")
                        .fontWeight(.medium)
                        .frame(width: 120, alignment: .trailing)
                    
                    Text("Kontakte")
                        .fontWeight(.medium)
                        .frame(width: 80, alignment: .trailing)
                    
                    Text("Gesamtkosten")
                        .fontWeight(.medium)
                        .frame(width: 120, alignment: .trailing)
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.secondary.opacity(0.2))
                
                // Zeilen
                ForEach(phasen) { phase in
                    VStack(spacing: 0) {
                        HStack {
                            Text(phase.phase.rawValue)
                                .font(.subheadline)
                                .frame(width: 150, alignment: .leading)
                            
                            Spacer()
                            
                            Text("€\(String(format: "%.2f", phase.kosten))")
                                .font(.subheadline)
                                .frame(width: 120, alignment: .trailing)
                            
                            Text("\(phase.anzahlKontakte)")
                                .font(.subheadline)
                                .frame(width: 80, alignment: .trailing)
                            
                            let gesamtkosten = phase.kosten * Double(phase.anzahlKontakte)
                            
                            Text("€\(String(format: "%.2f", gesamtkosten))")
                                .font(.subheadline)
                                .frame(width: 120, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color(NSColor.windowBackgroundColor))
                        
                        Divider()
                    }
                }
                
                // Gesamtsumme
                HStack {
                    Text("Gesamt")
                        .font(.headline)
                        .frame(width: 150, alignment: .leading)
                    
                    Spacer()
                    
                    let durchschnittskosten = phasen.map { $0.kosten }.reduce(0, +) / Double(max(1, phasen.count))
                    
                    Text("€\(String(format: "%.2f", durchschnittskosten))")
                        .font(.headline)
                        .frame(width: 120, alignment: .trailing)
                    
                    let gesamtkontakte = phasen.map { $0.anzahlKontakte }.reduce(0, +)
                    
                    Text("\(gesamtkontakte)")
                        .font(.headline)
                        .frame(width: 80, alignment: .trailing)
                    
                    let gesamtkosten = phasen.reduce(0) { $0 + ($1.kosten * Double($1.anzahlKontakte)) }
                    
                    Text("€\(String(format: "%.2f", gesamtkosten))")
                        .font(.headline)
                        .frame(width: 120, alignment: .trailing)
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.secondary.opacity(0.1))
            }
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct KundenreiseKonversionView: View {
    let phasen: [KundenPhaseDaten]
    
    var body: some View {
        VStack(spacing: 20) {
            // Konversionsraten
            Chart {
                ForEach(phasen) { phase in
                    BarMark(
                        x: .value("Phase", phase.phase.rawValue),
                        y: .value("Konversionsrate", phase.konversionsrate)
                    )
                    .foregroundStyle(by: .value("Phase", phase.phase.rawValue))
                }
                
                RuleMark(
                    y: .value("Durchschnitt", phasen.map { $0.konversionsrate }.reduce(0, +) / Double(max(1, phasen.count)))
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .annotation(position: .top, alignment: .trailing) {
                    Text("Durchschnitt")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel {
                        if let string = value.as(String.self) {
                            Text(string)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let value = value.as(Double.self) {
                            Text("\(String(format: "%.0f", value))%")
                                .font(.caption)
                        }
                    }
                }
            }
            
            // Trichter
            Chart {
                ForEach(phasen) { phase in
                    BarMark(
                        x: .value("Anzahl", phase.anzahlKontakte),
                        y: .value("Phase", phase.phase.rawValue)
                    )
                    .foregroundStyle(by: .value("Phase", phase.phase.rawValue))
                }
            }
            .frame(height: 250)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let value = value.as(Int.self) {
                            Text("\(value)")
                                .font(.caption)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel {
                        if let string = value.as(String.self) {
                            Text(string)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            // Konversionstabelle
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Phase")
                        .fontWeight(.medium)
                        .frame(width: 150, alignment: .leading)
                    
                    Spacer()
                    
                    Text("Start")
                        .fontWeight(.medium)
                        .frame(width: 80, alignment: .trailing)
                    
                    Text("Ende")
                        .fontWeight(.medium)
                        .frame(width: 80, alignment: .trailing)
                    
                    Text("Konversionsrate")
                        .fontWeight(.medium)
                        .frame(width: 120, alignment: .trailing)
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.secondary.opacity(0.2))
                
                // Zeilen
                ForEach(0..<phasen.count) { index in
                    let phase = phasen[index]
                    let vorherigePhaseMenge = index > 0 ? phasen[index - 1].anzahlKontakte : phase.anzahlKontakte
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text(phase.phase.rawValue)
                                .font(.subheadline)
                                .frame(width: 150, alignment: .leading)
                            
                            Spacer()
                            
                            Text("\(vorherigePhaseMenge)")
                                .font(.subheadline)
                                .frame(width: 80, alignment: .trailing)
                            
                            Text("\(phase.anzahlKontakte)")
                                .font(.subheadline)
                                .frame(width: 80, alignment: .trailing)
                            
                            Text("\(String(format: "%.1f", phase.konversionsrate))%")
                                .font(.subheadline)
                                .frame(width: 120, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color(NSColor.windowBackgroundColor))
                        
                        Divider()
                    }
                }
                
                // Gesamtkonversion
                HStack {
                    Text("Gesamt (Lead zu Abschluss)")
                        .font(.headline)
                        .frame(width: 150, alignment: .leading)
                    
                    Spacer()
                    
                    let erstePhaseMenge = phasen.first?.anzahlKontakte ?? 0
                    let letztePhaseMenge = phasen.last?.anzahlKontakte ?? 0
                    
                    Text("\(erstePhaseMenge)")
                        .font(.headline)
                        .frame(width: 80, alignment: .trailing)
                    
                    Text("\(letztePhaseMenge)")
                        .font(.headline)
                        .frame(width: 80, alignment: .trailing)
                    
                    let gesamtkonversion = erstePhaseMenge > 0 ? Double(letztePhaseMenge) / Double(erstePhaseMenge) * 100 : 0
                    
                    Text("\(String(format: "%.2f", gesamtkonversion))%")
                        .font(.headline)
                        .frame(width: 120, alignment: .trailing)
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.secondary.opacity(0.1))
            }
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct KundenreiseZeitverlaufView: View {
    let phasen: [KundenPhaseDaten]
    
    var body: some View {
        VStack(spacing: 20) {
            // Zeitverlauf-Chart
            Chart {
                ForEach(phasen) { phase in
                    BarMark(
                        x: .value("Phase", phase.phase.rawValue),
                        y: .value("Dauer", phase.durchschnittlicheDauer)
                    )
                    .foregroundStyle(by: .value("Phase", phase.phase.rawValue))
                }
                
                RuleMark(
                    y: .value("Durchschnitt", phasen.map { $0.durchschnittlicheDauer }.reduce(0, +) / max(1, phasen.count))
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .annotation(position: .top, alignment: .trailing) {
                    Text("Durchschnitt")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 250)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel {
                        if let string = value.as(String.self) {
                            Text(string)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let value = value.as(Int.self) {
                            Text("\(value) Tage")
                                .font(.caption)
                        }
                    }
                }
            }
            
            // Gantt-Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Zeitlicher Verlauf der Kundenreise")
                    .font(.headline)
                
                let gesamtdauer = phasen.reduce(0) { $0 + $1.durchschnittlicheDauer }
                
                ForEach(phasen) { phase in
                    let startTag = phasen.prefix(while: { $0.id != phase.id }).reduce(0) { $0 + $1.durchschnittlicheDauer }
                    let breite = Double(phase.durchschnittlicheDauer) / Double(gesamtdauer)
                    
                    HStack(spacing: 8) {
                        Text(phase.phase.rawValue)
                            .font(.subheadline)
                            .frame(width: 120, alignment: .leading)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: geometry.size.width)
                                
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: geometry.size.width * CGFloat(breite))
                                    .offset(x: geometry.size.width * CGFloat(Double(startTag) / Double(gesamtdauer)))
                                    .overlay(
                                        Text("\(phase.durchschnittlicheDauer) Tage")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 4)
                                    )
                            }
                            .frame(height: 24)
                            .cornerRadius(4)
                        }
                    }
                    .frame(height: 30)
                }
                
                // Zeitskala
                HStack(spacing: 0) {
                    Text("")
                        .frame(width: 120, alignment: .leading)
                    
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            ForEach(0...4, id: \.self) { i in
                                VStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(width: 1, height: 8)
                                    
                                    Text("\(i * (gesamtdauer / 4)) Tage")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: geometry.size.width / 4, alignment: .leading)
                            }
                        }
                    }
                }
                .frame(height: 30)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            
            // Zeittabelle
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Phase")
                                            .fontWeight(.medium)
                                            .frame(width: 150, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        Text("Dauer")
                                            .fontWeight(.medium)
                                            .frame(width: 80, alignment: .trailing)
                                        
                                        Text("Start (Tag)")
                                            .fontWeight(.medium)
                                            .frame(width: 80, alignment: .trailing)
                                        
                                        Text("Ende (Tag)")
                                            .fontWeight(.medium)
                                            .frame(width: 80, alignment: .trailing)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .background(Color.secondary.opacity(0.2))
                                    
                                    // Zeilen
                                    var aktuellerTag = 0
                                    
                                    ForEach(phasen) { phase in
                                        let startTag = aktuellerTag
                                        let endeTag = startTag + phase.durchschnittlicheDauer
                                        
                                        VStack(spacing: 0) {
                                            HStack {
                                                Text(phase.phase.rawValue)
                                                    .font(.subheadline)
                                                    .frame(width: 150, alignment: .leading)
                                                
                                                Spacer()
                                                
                                                Text("\(phase.durchschnittlicheDauer) Tage")
                                                    .font(.subheadline)
                                                    .frame(width: 80, alignment: .trailing)
                                                
                                                Text("\(startTag)")
                                                    .font(.subheadline)
                                                    .frame(width: 80, alignment: .trailing)
                                                
                                                Text("\(endeTag)")
                                                    .font(.subheadline)
                                                    .frame(width: 80, alignment: .trailing)
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal)
                                            .background(Color(NSColor.windowBackgroundColor))
                                            
                                            Divider()
                                        }
                                        
                                        let _ = {
                                            // Aktuellen Tag für die nächste Phase aktualisieren
                                            aktuellerTag = endeTag
                                        }()
                                    }
                                    
                                    // Gesamtdauer
                                    HStack {
                                        Text("Gesamtdauer")
                                            .font(.headline)
                                            .frame(width: 150, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        let gesamtdauer = phasen.reduce(0) { $0 + $1.durchschnittlicheDauer }
                                        
                                        Text("\(gesamtdauer) Tage")
                                            .font(.headline)
                                            .frame(width: 80, alignment: .trailing)
                                        
                                        Text("0")
                                            .font(.headline)
                                            .frame(width: 80, alignment: .trailing)
                                        
                                        Text("\(gesamtdauer)")
                                            .font(.headline)
                                            .frame(width: 80, alignment: .trailing)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .background(Color.secondary.opacity(0.1))
                                }
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }

                    struct InfoKarteView: View {
                        let titel: String
                        let wert: String
                        let untertitel: String
                        let symbol: String
                        let farbe: Color
                        
                        var body: some View {
                            VStack(alignment: .center, spacing: 8) {
                                HStack {
                                    Image(systemName: symbol)
                                        .font(.title2)
                                        .foregroundColor(farbe)
                                    
                                    Text(titel)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(wert)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(untertitel)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.05))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(farbe.opacity(0.3), lineWidth: 2)
                            )
                        }
                    }

// Diesen Code-Block in der KundenreiseView.swift Datei suchen und ersetzen
struct KundenPhaseBearbeitenView: View {
    @State private var phasenDaten: KundenPhaseDaten
    let onSave: (KundenPhaseDaten) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(phasenDaten: KundenPhaseDaten, onSave: @escaping (KundenPhaseDaten) -> Void) {
        self._phasenDaten = State(initialValue: phasenDaten)
        self.onSave = onSave
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("\(phasenDaten.phase.rawValue) bearbeiten")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            // Kontakte
            VStack(alignment: .leading, spacing: 10) {
                Text("Kontakte")
                    .font(.headline)
                
                HStack {
                    Text("Anzahl Kontakte:")
                    Spacer()
                    TextField("", value: $phasenDaten.anzahlKontakte, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
            
            // Konversionsrate
            VStack(alignment: .leading, spacing: 10) {
                Text("Konversionsrate")
                    .font(.headline)
                
                Text("\(Int(phasenDaten.konversionsrate))%")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Slider(value: $phasenDaten.konversionsrate, in: 1...100, step: 1)
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            
            // Kosten
            VStack(alignment: .leading, spacing: 10) {
                Text("Kosten")
                    .font(.headline)
                
                HStack {
                    Text("Kosten pro Kontakt:")
                    Spacer()
                    TextField("", value: $phasenDaten.kosten, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                    Text("€")
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
            
            // Dauer
            VStack(alignment: .leading, spacing: 10) {
                Text("Dauer")
                    .font(.headline)
                
                HStack {
                    Text("Durchschnittliche Dauer: \(phasenDaten.durchschnittlicheDauer) Tage")
                    Spacer()
                    Stepper("", value: $phasenDaten.durchschnittlicheDauer, in: 1...90)
                        .labelsHidden()
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Buttons
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Text("Abbrechen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    onSave(phasenDaten)
                    dismiss()
                }) {
                    Text("Speichern")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding([.horizontal, .bottom])
        }
        .frame(width: 450, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
