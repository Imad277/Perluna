//
//  MarketingAnalyseView.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI

struct MarketingAnalyseView: View {
    let projekt: Projekt
    @State private var gesamtbudget: Double = 100000
    @State private var zielgruppe: String = "Investoren"
    @State private var marketingKanäle: [MarketingKanal] = [
        MarketingKanal(name: "Social Media", budgetAnteil: 0.25, geschätzteCPL: 50, geschätzteCPK: 500),
        MarketingKanal(name: "SEA", budgetAnteil: 0.20, geschätzteCPL: 70, geschätzteCPK: 700),
        MarketingKanal(name: "Content Marketing", budgetAnteil: 0.15, geschätzteCPL: 40, geschätzteCPK: 400),
        MarketingKanal(name: "PR", budgetAnteil: 0.15, geschätzteCPL: 100, geschätzteCPK: 1000),
        MarketingKanal(name: "Events", budgetAnteil: 0.25, geschätzteCPL: 200, geschätzteCPK: 2000)
    ]
    @State private var zeigeKanalHinzufügen = false
    @EnvironmentObject var projektManager: ProjektManager
    @State private var kundenPhasen: [KundenPhaseDaten] = []
    @State private var bruttoKonversionsraten: [String: Double] = [:]
    @State private var nettoKonversionsraten: [String: Double] = [:]
    
    let zielgruppenOptionen = ["Privatkunden", "KMU", "Großunternehmen", "Investoren", "Institutionen"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Marketinganalyse")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Schätzen Sie die erwarteten Marketingkosten und -effekte für Ihr Projekt ein")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Grundeinstellungen
                VStack(alignment: .leading, spacing: 16) {
                    Text("Grundeinstellungen")
                        .font(.headline)
                    
                    // Gesamtbudget
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Marketingbudget gesamt:")
                            .fontWeight(.medium)
                        
                        HStack {
                            TextField("", value: $gesamtbudget, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: gesamtbudget) { newValue in
                                    aktualisiereDatenNachBudgetÄnderung()
                                }
                            
                            Text("€")
                                .fontWeight(.bold)
                        }
                        
                        Slider(value: $gesamtbudget, in: 10000...1000000, step: 10000)
                            .onChange(of: gesamtbudget) { newValue in
                                aktualisiereDatenNachBudgetÄnderung()
                            }
                    }
                    
                    // Zielgruppe
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Primäre Zielgruppe:")
                            .fontWeight(.medium)
                        
                        Picker("", selection: $zielgruppe) {
                            ForEach(zielgruppenOptionen, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onChange(of: zielgruppe) { newValue in
                            aktualisiereDatenNachZielgruppeÄnderung()
                        }
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                
                // Marketingkanäle
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Marketingkanäle")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            zeigeKanalHinzufügen.toggle()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Kanal hinzufügen")
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    ForEach(Array(marketingKanäle.enumerated()), id: \.element.id) { index, kanal in
                        MarketingKanalView(
                            kanal: Binding(
                                get: { marketingKanäle[index] },
                                set: { marketingKanäle[index] = $0 }
                            ),
                            gesamtbudget: gesamtbudget,
                            onRemove: {
                                marketingKanäle.remove(at: index)
                                aktualisiereKanäle()
                            }
                        )
                    }
                    
                    if marketingKanäle.isEmpty {
                        Text("Noch keine Marketingkanäle definiert")
                            .italic()
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                
                // Zusammenfassung
                VStack(alignment: .leading, spacing: 16) {
                    Text("Kostenübersicht")
                        .font(.headline)
                    
                    // Budgetverteilung
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Budgetverteilung nach Kanälen")
                            .fontWeight(.medium)
                        
                        ForEach(marketingKanäle, id: \.id) { kanal in
                            HStack {
                                Text(kanal.name)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("€\(String(format: "%.2f", kanal.budgetAnteil * gesamtbudget))")
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Gesamt")
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("€\(String(format: "%.2f", gesamtbudget))")
                                .fontWeight(.bold)
                        }
                    }
                    
                    // Erwartete Leads
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Erwartete Lead-Generierung")
                            .fontWeight(.medium)
                        
                        ForEach(marketingKanäle, id: \.id) { kanal in
                            let leads = (kanal.budgetAnteil * gesamtbudget) / kanal.geschätzteCPL
                            
                            HStack {
                                Text(kanal.name)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(Int(leads)) Leads")
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Divider()
                        
                        let gesamtLeads = marketingKanäle.reduce(0.0) { $0 + (($1.budgetAnteil * gesamtbudget) / $1.geschätzteCPL) }
                        
                        HStack {
                            Text("Gesamt")
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("\(Int(gesamtLeads)) Leads")
                                .fontWeight(.bold)
                        }
                    }
                    
                    // Konversionsraten-Übersicht
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Berechnete Konversionsraten")
                            .fontWeight(.medium)
                        
                        ForEach(marketingKanäle, id: \.id) { kanal in
                            let bruttoCVR = bruttoKonversionsraten[kanal.name] ?? 0
                            let nettoCVR = nettoKonversionsraten[kanal.name] ?? 0
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(kanal.name)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    Text("Brutto: \(String(format: "%.2f", bruttoCVR))%")
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    Text("Netto: \(String(format: "%.2f", nettoCVR))%")
                                        .font(.caption)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                
                // Hinweise
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hinweise zur Interpretation")
                        .font(.headline)
                    
                    Text("• Die Kostenberechnungen basieren auf Durchschnittswerten für die Branche \(projekt.branche)")
                        .font(.caption)
                    
                    Text("• Die tatsächlichen Kosten können je nach Marktlage und Wettbewerbssituation variieren")
                        .font(.caption)
                    
                    Text("• Regelmäßige Überprüfung und Anpassung der Marketingstrategie wird empfohlen")
                        .font(.caption)
                }
                .padding()
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            initializeData()
        }
        .sheet(isPresented: $zeigeKanalHinzufügen) {
            KanalHinzufügenView(onAdd: { neuerKanal in
                marketingKanäle.append(neuerKanal)
                aktualisiereKanäle()
                zeigeKanalHinzufügen = false
            })
        }
    }
    
    private func initializeData() {
        // Initialisiere das Gesamtbudget basierend auf dem Investitionsvolumen des Projekts
        gesamtbudget = max(projekt.investitionsvolumen * 0.05, 50000) // 5% des Investitionsvolumens als Marketingbudget, mindestens 50.000€
        
        // Berechne initiale Konversionsraten
        berechneKonversionsraten()
        
        // Erstelle Kundenreise-Phasen
        erstelleKundenphasen()
        
        // Speichere die Änderungen
        speichereÄnderungen()
    }
    
    private func aktualisiereKanäle() {
        // Sicherstellen, dass die Budgetanteile immer 100% ergeben
        let aktuellerGesamtanteil = marketingKanäle.reduce(0) { $0 + $1.budgetAnteil }
        
        if aktuellerGesamtanteil > 0 && marketingKanäle.count > 0 {
            let faktor = 1.0 / aktuellerGesamtanteil
            
            for i in 0..<marketingKanäle.count {
                marketingKanäle[i].budgetAnteil *= faktor
            }
        }
        
        // Konversionsraten neu berechnen
        berechneKonversionsraten()
        
        // Kundenreise-Phasen aktualisieren
        aktualisiereKundenphasen()
        
        // Speichere die Änderungen
        speichereÄnderungen()
    }
    
    private func aktualisiereDatenNachBudgetÄnderung() {
        // Konversionsraten neu berechnen
        berechneKonversionsraten()
        
        // Kundenreise-Phasen aktualisieren
        aktualisiereKundenphasen()
        
        // Speichere die Änderungen
        speichereÄnderungen()
    }
    
    private func aktualisiereDatenNachZielgruppeÄnderung() {
        // Konversionsraten neu berechnen
        berechneKonversionsraten()
        
        // Kundenreise-Phasen aktualisieren
        aktualisiereKundenphasen()
        
        // Speichere die Änderungen
        speichereÄnderungen()
    }
    
    private func berechneKonversionsraten() {
        let berechnungsService = BerechnungsService()
        
        for kanal in marketingKanäle {
            let (brutto, netto) = berechnungsService.berechneBruttoUndNettoKonversionsrate(
                branche: projekt.branche,
                marketingKanal: kanal.name,
                zielgruppe: zielgruppe
            )
            
            // Passe Konversionsraten basierend auf Budget an
            let budgetFaktor = sqrt(kanal.budgetAnteil * gesamtbudget / 50000) // Quadratwurzel für gedämpfte Skalierung
            let angepassteBruttoRate = brutto * budgetFaktor
            let angepassteNettoRate = netto * budgetFaktor
            
            bruttoKonversionsraten[kanal.name] = angepassteBruttoRate
            nettoKonversionsraten[kanal.name] = angepassteNettoRate
        }
    }
    
    private func erstelleKundenphasen() {
        let berechnungsService = BerechnungsService()
        var phasen: [KundenPhaseDaten] = []
        
        // Berechne die Gesamtzahl der generierten Leads
        let gesamtLeads = marketingKanäle.reduce(0.0) { $0 + (($1.budgetAnteil * gesamtbudget) / $1.geschätzteCPL) }
        var anzahlKontakte = Int(gesamtLeads)
        
        // Durchschnittliche Konversionsrate berechnen
        let durchschnittlicheNettoKonversionsrate = nettoKonversionsraten.values.reduce(0, +) / max(1, Double(nettoKonversionsraten.count))
        
        // Für jede Phase der Kundenreise
        for phase in KundenPhase.allCases {
            let (kosten, konversionsrate) = berechnungsService.berechneKundenreiseKosten(branche: projekt.branche, phase: phase)
            
            // Für die erste Phase (Lead-Generierung) verwenden wir die gesamte Anzahl der Leads
            if phase == .leadGenerierung {
                phasen.append(KundenPhaseDaten(
                    phase: phase,
                    anzahlKontakte: anzahlKontakte,
                    konversionsrate: konversionsrate,
                    kosten: kosten,
                    durchschnittlicheDauer: 7
                ))
            } else {
                // Für alle anderen Phasen berechnen wir die Anzahl der Kontakte basierend auf der Konversionsrate der vorherigen Phase
                if let vorherigePhaseDaten = phasen.last {
                    anzahlKontakte = Int(Double(vorherigePhaseDaten.anzahlKontakte) * vorherigePhaseDaten.konversionsrate / 100.0)
                    
                    let angepassteKonversionsrate = konversionsrate * (1.0 + (durchschnittlicheNettoKonversionsrate - 2.0) / 10.0)
                    
                    phasen.append(KundenPhaseDaten(
                        phase: phase,
                        anzahlKontakte: anzahlKontakte,
                        konversionsrate: angepassteKonversionsrate,
                        kosten: kosten * (gesamtbudget / 100000), // Skaliere Kosten mit Budget
                        durchschnittlicheDauer: phase == .qualifizierung || phase == .letterOfIntent ? 14 : 7
                    ))
                }
            }
        }
        
        kundenPhasen = phasen
    }
    
    private func aktualisiereKundenphasen() {
        // Wenn kundenPhasen leer ist, erstelle sie neu
        if kundenPhasen.isEmpty {
            erstelleKundenphasen()
            return
        }
        
        let berechnungsService = BerechnungsService()
        
        // Berechne die Gesamtzahl der generierten Leads
        let gesamtLeads = marketingKanäle.reduce(0.0) { $0 + (($1.budgetAnteil * gesamtbudget) / $1.geschätzteCPL) }
        var anzahlKontakte = Int(gesamtLeads)
        
        // Durchschnittliche Konversionsrate berechnen
        let durchschnittlicheNettoKonversionsrate = nettoKonversionsraten.values.reduce(0, +) / max(1, Double(nettoKonversionsraten.count))
        
        // Aktualisiere jede Phase
        for i in 0..<kundenPhasen.count {
            let phase = kundenPhasen[i].phase
            let (kosten, basisKonversionsrate) = berechnungsService.berechneKundenreiseKosten(branche: projekt.branche, phase: phase)
            
            // Für die erste Phase (Lead-Generierung) verwenden wir die gesamte Anzahl der Leads
            if phase == .leadGenerierung {
                kundenPhasen[i].anzahlKontakte = anzahlKontakte
            } else {
                // Für alle anderen Phasen berechnen wir die Anzahl der Kontakte basierend auf der Konversionsrate der vorherigen Phase
                if i > 0 {
                    let vorherigePhaseDaten = kundenPhasen[i-1]
                    anzahlKontakte = Int(Double(vorherigePhaseDaten.anzahlKontakte) * vorherigePhaseDaten.konversionsrate / 100.0)
                    kundenPhasen[i].anzahlKontakte = anzahlKontakte
                }
            }
            
            // Anpassung der Konversionsrate basierend auf dem Budget und der durchschnittlichen Netto-Konversionsrate
            let budgetFaktor = sqrt(gesamtbudget / 100000) // Quadratwurzel für gedämpfte Skalierung
            let angepassteKonversionsrate = basisKonversionsrate * (1.0 + (durchschnittlicheNettoKonversionsrate - 2.0) / 10.0) * budgetFaktor
            
            kundenPhasen[i].konversionsrate = min(angepassteKonversionsrate, 99.0) // Maximale Konversionsrate auf 99% begrenzen
            kundenPhasen[i].kosten = kosten * (gesamtbudget / 100000) // Skaliere Kosten mit Budget
        }
    }
    
    private func speichereÄnderungen() {
        // Erstelle eine MarketingDaten-Instanz
        let marketingDaten = MarketingDaten(
            projektID: projekt.id,
            branche: projekt.branche,
            zielgruppe: zielgruppe,
            kanäle: marketingKanäle,
            gesamtbudget: gesamtbudget
        )
        
        // Erstelle eine KonversionsDaten-Instanz
        let konversionsDaten = KonversionsDaten(
            projektID: projekt.id,
            marketingKanäle: marketingKanäle.map { $0.name },
            bruttoKonversionsraten: bruttoKonversionsraten,
            nettoKonversionsraten: nettoKonversionsraten
        )
        
        // Erstelle eine KundenReise-Instanz
        let kundenReise = KundenReise(
            projektID: projekt.id,
            phasenDaten: kundenPhasen
        )
        
        // Hier würden wir normalerweise diese Daten im ProjektManager speichern
        // Da wir aber nicht die volle Implementation des ProjektManagers kennen,
        // zeigen wir nur, wie die Daten erstellt werden
        
        // Für eine vollständige Implementierung müsste der ProjektManager erweitert werden,
        // um diese zusätzlichen Datenstrukturen zu unterstützen
        
        // Beispiel (wenn der ProjektManager diese Funktionen hätte):
        // projektManager.updateMarketingDaten(marketingDaten)
        // projektManager.updateKonversionsDaten(konversionsDaten)
        // projektManager.updateKundenReise(kundenReise)
        
        // Für jetzt aktualisieren wir nur das Projekt selbst
        var aktualisierteProjekt = projekt
        // Hier könnten wir Projekt-Eigenschaften aktualisieren, wenn nötig
        projektManager.aktualisiereProjekt(projekt: aktualisierteProjekt)
        // Benachrichtigung senden, dass sich die Marketingdaten geändert haben
        NotificationCenter.default.post(name: NSNotification.Name("MarketingDatenGeändert"), object: nil)
    }
}

struct MarketingKanalView: View {
    @Binding var kanal: MarketingKanal
    let gesamtbudget: Double
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(kanal.name)
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    Button(role: .destructive, action: onRemove) {
                        Label("Entfernen", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Budgetanteil: \(Int(kanal.budgetAnteil * 100))%")
                    .font(.subheadline)
                
                Slider(value: $kanal.budgetAnteil, in: 0.05...1.0, step: 0.05)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("CPL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("", value: $kanal.geschätzteCPL, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        
                        Text("€")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("CPK")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("", value: $kanal.geschätzteCPK, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        
                        Text("€")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("€\(String(format: "%.2f", kanal.budgetAnteil * gesamtbudget))")
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct KanalHinzufügenView: View {
    let onAdd: (MarketingKanal) -> Void
    
    @State private var kanalName: String = ""
    @State private var budgetAnteil: Double = 0.1
    @State private var geschätzteCPL: Double = 50
    @State private var geschätzteCPK: Double = 500
    @Environment(\.dismiss) private var dismiss
    
    let kanalVorschläge = [
        "Email Marketing", "Messen", "Direktmarketing", "Influencer",
        "Partnerschaften", "Affiliate", "Outdoor", "Print", "TV/Radio"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Marketingkanal hinzufügen")
                .font(.title2)
                .fontWeight(.bold)
            
            Form {
                Section(header: Text("Kanaldetails")) {
                    TextField("Kanalname", text: $kanalName)
                    
                    HStack {
                        Text("CPL (Cost per Lead)")
                        Spacer()
                        TextField("", value: $geschätzteCPL, formatter: NumberFormatter())
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("€")
                    }
                    
                    HStack {
                        Text("CPK (Cost per Kunde)")
                        Spacer()
                        TextField("", value: $geschätzteCPK, formatter: NumberFormatter())
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("€")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Budgetanteil: \(Int(budgetAnteil * 100))%")
                        Slider(value: $budgetAnteil, in: 0.05...1.0, step: 0.05)
                    }
                }
                
                Section(header: Text("Vorschläge")) {
                    ForEach(kanalVorschläge, id: \.self) { vorschlag in
                        Button(action: {
                            kanalName = vorschlag
                        }) {
                            HStack {
                                Text(vorschlag)
                                Spacer()
                                if kanalName == vorschlag {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
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
                    onAdd(MarketingKanal(
                        name: kanalName.isEmpty ? "Neuer Kanal" : kanalName,
                        budgetAnteil: budgetAnteil,
                        geschätzteCPL: geschätzteCPL,
                        geschätzteCPK: geschätzteCPK
                    ))
                }) {
                    Text("Hinzufügen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(kanalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .frame(width: 500, height: 600)
    }
}
