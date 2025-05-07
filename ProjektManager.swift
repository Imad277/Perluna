//
//  ProjektManager.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import Foundation
import Combine

class ProjektManager: ObservableObject {
    @Published var projekte: [Projekt] = []
    @Published var ausgewähltesProjekt: Projekt?
    @Published var zeigeNeuesProjektDialog = false
    @Published var zeigePDFImportDialog = false
    @Published var isEditingProject = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadDemoProjects()
        
        // Automatisches Speichern bei Änderungen
        $projekte
            .debounce(for: 2.0, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.speicherProjekte()
            }
            .store(in: &cancellables)
    }
    
    private func loadDemoProjects() {
        // Demo-Projekte laden (in einer realen App würde dies aus einer Datei oder Datenbank geladen)
        projekte = [
            Projekt(
                name: "Smart City Initiative",
                beschreibung: "Entwicklung einer Smart-City-Plattform für mittelgroße Städte mit IoT-Integration und KI-gestützter Verkehrssteuerung.",
                branche: "Technologie",
                investitionsvolumen: 2500000,
                laufzeit: 48,
                renditeZiel: 8.5,
                risikoParameter: [
                    "Marktpotenzial": 8,
                    "Teamkompetenz": 7,
                    "Finanzplanung": 6,
                    "Wettbewerbssituation": 9,
                    "Innovationsgrad": 8,
                    "Skalierbarkeit": 7
                ],
                erstelltAm: Date(),
                aktualisertAm: Date()
            ),
            
            Projekt(
                name: "Wohnkomplex Berlin-Mitte",
                beschreibung: "Entwicklung eines nachhaltigen Wohnkomplexes mit 60 Einheiten in zentraler Lage, inkl. Gemeinschaftsflächen und erneuerbaren Energiekonzept.",
                branche: "Immobilien",
                investitionsvolumen: 18500000,
                laufzeit: 36,
                renditeZiel: 6.2,
                risikoParameter: [
                    "Marktpotenzial": 7,
                    "Teamkompetenz": 8,
                    "Finanzplanung": 9,
                    "Wettbewerbssituation": 6,
                    "Rechtliche Risiken": 7,
                    "Standortqualität": 9
                ],
                erstelltAm: Date().addingTimeInterval(-86400 * 30), // 30 Tage zurück
                aktualisertAm: Date().addingTimeInterval(-86400 * 2) // 2 Tage zurück
            ),
            
            Projekt(
                name: "FinHealth SaaS-Lösung",
                beschreibung: "Cloud-basierte Finanz-Management-Software speziell für Gesundheitsdienstleister mit regulatorischer Compliance und Abrechnungsoptimierung.",
                branche: "Finanzen",
                investitionsvolumen: 750000,
                laufzeit: 24,
                renditeZiel: 12.0,
                risikoParameter: [
                    "Marktpotenzial": 9,
                    "Teamkompetenz": 6,
                    "Finanzplanung": 7,
                    "Wettbewerbssituation": 5,
                    "Innovationsgrad": 8,
                    "Skalierbarkeit": 9,
                    "Regulatorische Risiken": 4
                ],
                erstelltAm: Date().addingTimeInterval(-86400 * 60), // 60 Tage zurück
                aktualisertAm: Date().addingTimeInterval(-86400 * 15) // 15 Tage zurück
            )
        ]
    }
    
    func erstelleProjekt(projekt: Projekt) {
        projekte.append(projekt)
        ausgewähltesProjekt = projekt
    }
    
    func aktualisiereProjekt(projekt: Projekt) {
        if let index = projekte.firstIndex(where: { $0.id == projekt.id }) {
            var aktualisierteProjekt = projekt
            aktualisierteProjekt.aktualisertAm = Date()
            projekte[index] = aktualisierteProjekt
            
            if ausgewähltesProjekt?.id == projekt.id {
                ausgewähltesProjekt = aktualisierteProjekt
            }
        }
    }
    
    func löscheProjekt(id: UUID) {
        projekte.removeAll(where: { $0.id == id })
        
        if ausgewähltesProjekt?.id == id {
            ausgewähltesProjekt = nil
        }
    }
    
    func projektNachId(_ id: UUID) -> Projekt? {
        return projekte.first(where: { $0.id == id })
    }
    
    private func speicherProjekte() {
        // In einer realen App würde hier die Speicherung in einer Datei oder Datenbank erfolgen
        print("Projekte gespeichert: \(projekte.count) Projekte")
    }
}
