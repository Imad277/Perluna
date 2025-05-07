//
//  ErfolgsberechnungView.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI

struct ErfolgsberechnungView: View {
    let projekt: Projekt
    @State private var risikoParameter: [String: Int]
    @State private var gesamtwahrscheinlichkeit: Double = 0
    @EnvironmentObject var projektManager: ProjektManager
    
    init(projekt: Projekt) {
        self.projekt = projekt
        self._risikoParameter = State(initialValue: projekt.risikoParameter)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Erfolgswahrscheinlichkeit berechnen")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Bewerten Sie die Erfolgsfaktoren des Projekts auf einer Skala von 1 (sehr niedrig) bis 10 (sehr hoch). Die maximale Erfolgswahrscheinlichkeit ist auf 90% begrenzt.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Risikofaktoren
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(risikoParameter.keys.sorted()), id: \.self) { key in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(key)
                                .font(.headline)
                            
                            HStack {
                                Text("1")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Slider(value: Binding(
                                    get: { Double(risikoParameter[key] ?? 5) },
                                    set: { newValue in
                                        risikoParameter[key] = Int(newValue)
                                        berechneGesamtwahrscheinlichkeit()
                                        speichereParameterÄnderungen()
                                    }
                                ), in: 1...10, step: 1)
                                
                                Text("10")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(risikoParameter[key] ?? 0)")
                                    .font(.headline)
                                    .frame(width: 30)
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Button zum Hinzufügen eines neuen Parameters
                    Button(action: {
                        let neueParameter = ["Rechtliche Risiken", "Skalierbarkeit", "Wettbewerbssituation", "Innovationsgrad"]
                        
                        for param in neueParameter {
                            if !risikoParameter.keys.contains(param) {
                                risikoParameter[param] = 5
                                berechneGesamtwahrscheinlichkeit()
                                speichereParameterÄnderungen()
                                break
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Weiteren Faktor hinzufügen")
                        }
                        .padding()
                    }
                }
                
                Divider()
                
                // Ergebnis
                VStack(alignment: .center, spacing: 10) {
                    Text("Berechnete Erfolgswahrscheinlichkeit")
                        .font(.headline)
                    
                    Text("\(Int(gesamtwahrscheinlichkeit))%")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(farbeFürWahrscheinlichkeit(gesamtwahrscheinlichkeit))
                    
                    ProgressView(value: gesamtwahrscheinlichkeit, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: farbeFürWahrscheinlichkeit(gesamtwahrscheinlichkeit)))
                        .frame(height: 10)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            berechneGesamtwahrscheinlichkeit()
        }
    }
    
    private func berechneGesamtwahrscheinlichkeit() {
        let berechnungsService = BerechnungsService()
        gesamtwahrscheinlichkeit = berechnungsService.berechneErfolgswahrscheinlichkeit(parameter: risikoParameter)
    }
    
    private func speichereParameterÄnderungen() {
        // Erstelle eine Kopie des aktuellen Projekts
        var aktualisierteProjekt = projekt
        
        // Aktualisiere die Risikoparameter
        aktualisierteProjekt.risikoParameter = risikoParameter
        
        // Speichere das aktualisierte Projekt im ProjektManager
        projektManager.aktualisiereProjekt(projekt: aktualisierteProjekt)
    }
    
    private func farbeFürWahrscheinlichkeit(_ wahrscheinlichkeit: Double) -> Color {
        if wahrscheinlichkeit < 30 {
            return .red
        } else if wahrscheinlichkeit < 50 {
            return .orange
        } else if wahrscheinlichkeit < 75 {
            return .yellow
        } else {
            return .green
        }
    }
}
