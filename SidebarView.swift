//
//  SidebarView.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var projektManager: ProjektManager
    @State private var ausgewähltesFilter: ProjektFilter = .alle
    
    enum ProjektFilter: String, CaseIterable, Identifiable {
        case alle = "Alle Projekte"
        case aktiv = "Aktive Projekte"
        case archiviert = "Archivierte Projekte"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        List(selection: $projektManager.ausgewähltesProjekt) {
            Section(header: Text("Filter")) {
                ForEach(ProjektFilter.allCases) { filter in
                    Text(filter.rawValue)
                        .font(.subheadline)
                        .tag(filter)
                        .onTapGesture {
                            ausgewähltesFilter = filter
                        }
                }
            }
            
            Section(header: Text("Projekte")) {
                ForEach(projektManager.projekte) { projekt in
                    NavigationLink(value: projekt) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis.circle")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(projekt.name)
                                    .font(.headline)
                                Text("€\(projekt.investitionsvolumen, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .contextMenu {
                        Button(action: {
                            // Projekt bearbeiten
                            projektManager.isEditingProject = true
                        }) {
                            Label("Bearbeiten", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            // Projekt löschen
                            projektManager.löscheProjekt(id: projekt.id)
                        }) {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .toolbar {
            ToolbarItem {
                Button(action: {
                    projektManager.zeigeNeuesProjektDialog = true
                }) {
                    Label("Neues Projekt", systemImage: "plus")
                }
            }
        }
    }
}
