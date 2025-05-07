//
//  DetailView.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI
import Charts

struct DetailView: View {
    let projekt: Projekt
    @State private var ausgewählterTab = 0
    @EnvironmentObject var projektManager: ProjektManager
    
    var body: some View {
        TabView(selection: $ausgewählterTab) {
            // Übersicht
            ProjektÜbersichtView(projekt: projekt)
                .tabItem {
                    Label("Übersicht", systemImage: "doc.text")
                }
                .tag(0)
            
            // Erfolgsberechnung
            ErfolgsberechnungView(projekt: projekt)
                .tabItem {
                    Label("Erfolgsberechnung", systemImage: "percent")
                }
                .tag(1)
            
            // Marketing
            MarketingAnalyseView(projekt: projekt)
                .tabItem {
                    Label("Marketing", systemImage: "megaphone")
                }
                .tag(2)
            
            // Konversion
            KonversionsAnalyseView(projekt: projekt)
                .tabItem {
                    Label("Konversion", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(3)
            
            // Kundenreise
            KundenreiseView(projekt: projekt)
                .tabItem {
                    Label("Kundenreise", systemImage: "figure.walk")
                }
                .tag(4)
            
            // Visualisierung
            VisualisierungView(projekt: projekt)
                .tabItem {
                    Label("Charts", systemImage: "chart.bar.xaxis")
                }
                .tag(5)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        // Export-Funktion
                    }) {
                        Label("Exportieren", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        // Projekt bearbeiten
                        projektManager.isEditingProject = true
                    }) {
                        Label("Bearbeiten", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: {
                        // Projekt löschen
                        projektManager.löscheProjekt(id: projekt.id)
                    }) {
                        Label("Löschen", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}
