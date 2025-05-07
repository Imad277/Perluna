//
//  PDFImportView.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFImportView: View {
    @State private var selectedURL: URL?
    @State private var isImporting: Bool = false
    @State private var importergebnis: [String: Any]?
    @State private var verarbeitungsStatus: ImportStatus = .bereit
    @State private var fehlerMeldung: String?
    @State private var erkanntesProjekt: Projekt?
    @Environment(\.dismiss) private var dismiss
    
    enum ImportStatus {
        case bereit, verarbeitung, abgeschlossen, fehler
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Projektdaten aus PDF importieren")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Status-Anzeige
                HStack(spacing: 8) {
                    switch verarbeitungsStatus {
                    case .bereit:
                        Image(systemName: "doc.badge.plus")
                            .foregroundColor(.secondary)
                        Text("Bereit zum Import")
                            .foregroundColor(.secondary)
                    case .verarbeitung:
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Verarbeite PDF...")
                            .foregroundColor(.secondary)
                    case .abgeschlossen:
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Import abgeschlossen")
                            .foregroundColor(.green)
                    case .fehler:
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Fehler beim Import")
                            .foregroundColor(.red)
                    }
                }
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
            
            Divider()
            
            // Import-Bereich
            VStack(spacing: 25) {
                // Upload-Bereich
                VStack {
                    Button(action: {
                        isImporting = true
                    }) {
                        VStack(spacing: 15) {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.blue)
                            
                            Text("PDF-Datei auswählen")
                                .fontWeight(.medium)
                            
                            Text("Ziehen Sie eine PDF-Datei hierher oder klicken Sie, um eine Datei auszuwählen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                        .frame(maxWidth: .infinity)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 2)
                                .dashStyle(
                                    pattern: [8, 4],
                                    phase: 0
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if let url = selectedURL {
                        HStack {
                            Image(systemName: "doc.fill")
                                .foregroundColor(.blue)
                            
                            Text(url.lastPathComponent)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            
                            Spacer()
                            
                            Button(action: {
                                selectedURL = nil
                                importergebnis = nil
                                erkanntesProjekt = nil
                                verarbeitungsStatus = .bereit
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(10)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Erkannte Daten
                if let projekt = erkanntesProjekt {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Erkannte Projektdaten")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Group {
                            HStack {
                                Text("Projektname:")
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Text(projekt.name)
                            }
                            
                            HStack {
                                Text("Branche:")
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Text(projekt.branche)
                            }
                            
                            HStack {
                                Text("Investitionsvolumen:")
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Text("€\(projekt.investitionsvolumen, specifier: "%.2f")")
                            }
                        }
                        .padding(.leading)
                        
                        Divider()
                        
                        HStack {
                            Button(action: {
                                // Hier würde man das erkannte Projekt speichern und zurückkehren
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down.fill")
                                    Text("Projekt übernehmen")
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                // Hier würde man das Bearbeitungsformular öffnen
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Bearbeiten")
                                }
                                .padding()
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Fehlermeldung
                if let fehler = fehlerMeldung {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        
                        Text(fehler)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Buttons
            HStack {
                Button("Abbrechen") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Button("Importieren") {
                    // Import-Funktion
                    if let projekt = erkanntesProjekt {
                        // Projekt speichern und zurückkehren
                        dismiss()
                    } else {
                        fehlerMeldung = "Bitte wählen Sie zuerst eine PDF-Datei aus."
                    }
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(erkanntesProjekt == nil)
            }
            .padding()
        }
        .padding()
        .frame(width: 600, height: 700)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [UTType.pdf],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                
                selectedURL = selectedFile
                verarbeitungsStatus = .verarbeitung
                
                // Starten des PDF-Parsings
                // In einer realen App würde dies asynchron passieren
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        // Hier würde der echte PDF-Parser aufgerufen werden
                        // Für dieses Demo erstellen wir ein fiktives Ergebnis
                        
                        // Simuliere eine Verzögerung für realistischeres Demo
                        Thread.sleep(forTimeInterval: 1.5)
                        
                        let demoErgebnis: [String: Any] = [
                            "name": "Import: \(selectedFile.lastPathComponent)",
                            "beschreibung": "Automatisch importiertes Projekt aus PDF",
                            "branche": "Technologie",
                            "investitionsvolumen": 2500000.0,
                            "laufzeit": 36,
                            "renditeZiel": 9.5
                        ]
                        
                        DispatchQueue.main.async {
                            importergebnis = demoErgebnis
                            
                            // Demo-Projekt erstellen
                            erkanntesProjekt = Projekt(
                                name: demoErgebnis["name"] as? String ?? "Importiertes Projekt",
                                beschreibung: demoErgebnis["beschreibung"] as? String ?? "Importiert aus PDF",
                                branche: demoErgebnis["branche"] as? String ?? "Technologie",
                                investitionsvolumen: demoErgebnis["investitionsvolumen"] as? Double ?? 1000000.0,
                                laufzeit: demoErgebnis["laufzeit"] as? Int ?? 24,
                                renditeZiel: demoErgebnis["renditeZiel"] as? Double ?? 8.0,
                                risikoParameter: [
                                    "Marktpotenzial": 7,
                                    "Teamkompetenz": 6,
                                    "Finanzplanung": 8,
                                    "Wettbewerbssituation": 5,
                                    "Innovationsgrad": 7,
                                    "Skalierbarkeit": 8
                                ],
                                erstelltAm: Date(),
                                aktualisertAm: Date()
                            )
                            
                            verarbeitungsStatus = .abgeschlossen
                        }
                    } catch {
                        DispatchQueue.main.async {
                            fehlerMeldung = "Fehler beim Parsen der PDF: \(error.localizedDescription)"
                            verarbeitungsStatus = .fehler
                        }
                    }
                }
                
            } catch {
                fehlerMeldung = "Fehler beim Auswählen der Datei: \(error.localizedDescription)"
                verarbeitungsStatus = .fehler
            }
        }
    }
}

extension View {
    func dashStyle(pattern: [CGFloat], phase: CGFloat = 0) -> some View {
        self.overlay(
            DashPatternView(pattern: pattern, phase: phase)
        )
    }
}

struct DashPatternView: View {
    let pattern: [CGFloat]
    let phase: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Oben
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: width, y: 0))
                
                // Rechts
                path.move(to: CGPoint(x: width, y: 0))
                path.addLine(to: CGPoint(x: width, y: height))
                
                // Unten
                path.move(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                
                // Links
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: 0, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: pattern, dashPhase: phase))
        }
    }
}
