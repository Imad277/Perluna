//
//  ProjektFormView.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI

struct ProjektFormView: View {
    let onSave: (Projekt) -> Void
    
    @State private var name: String = ""
    @State private var beschreibung: String = ""
    @State private var branche: String = "Technologie"
    @State private var investitionsvolumen: Double = 1000000
    @State private var laufzeit: Int = 24
    @State private var renditeZiel: Double = 8.0
    
    let branchen = ["Technologie", "Immobilien", "Finanzen", "Konsumgüter", "Gesundheit", "Energie", "Bildung", "Transport", "Medien", "Andere"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Neues Projekt erstellen")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    onSave(Projekt(
                        name: name,
                        beschreibung: beschreibung,
                        branche: branche,
                        investitionsvolumen: investitionsvolumen,
                        laufzeit: laufzeit,
                        renditeZiel: renditeZiel,
                        risikoParameter: [
                            "Marktpotenzial": 5,
                            "Teamkompetenz": 5,
                            "Finanzplanung": 5,
                            "Wettbewerbssituation": 5,
                            "Innovationsgrad": 5,
                            "Skalierbarkeit": 5
                        ],
                        erstelltAm: Date(),
                        aktualisertAm: Date()
                    ))
                }) {
                    Text("Speichern")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            name.isEmpty ? Color.gray : Color.blue
                        )
                        .cornerRadius(8)
                }
                .disabled(name.isEmpty)
            }
            .padding()
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            // Formular
            Form {
                Section(header: Text("Grundinformationen")) {
                    TextField("Projektname", text: $name)
                    
                    Picker("Branche", selection: $branche) {
                        ForEach(branchen, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    TextEditor(text: $beschreibung)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if beschreibung.isEmpty {
                                    Text("Projektbeschreibung eingeben...")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                }
                
                Section(header: Text("Finanzielle Parameter")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Investitionsvolumen: €\(Int(investitionsvolumen))")
                        
                        Slider(value: $investitionsvolumen, in: 100000...10000000, step: 100000)
                    }
                    
                    Stepper("Laufzeit: \(laufzeit) Monate", value: $laufzeit, in: 1...120, step: 6)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rendite-Ziel: \(renditeZiel, specifier: "%.1f")%")
                        
                        Slider(value: $renditeZiel, in: 1...25, step: 0.5)
                    }
                }
                
                Section(header: Text("Hinweis")) {
                    Text("Nach dem Erstellen können Sie weitere Details und Risikoparameter im Projektbereich bearbeiten.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 600, height: 600)
    }
}
