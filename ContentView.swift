//
//  ContentView.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var projektManager: ProjektManager
    @State private var showingSidebar: Bool = true
    @State private var isSearching: Bool = false
    @State private var suchbegriff: String = ""
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
                .environmentObject(projektManager)
        } detail: {
            DetailContainer()
                .environmentObject(projektManager)
        }
        .navigationTitle("FundingForce")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    withAnimation {
                        showingSidebar.toggle()
                    }
                }) {
                    Image(systemName: "sidebar.left")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isSearching.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    projektManager.zeigeNeuesProjektDialog = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .searchable(text: $suchbegriff, isPresented: $isSearching, prompt: "Projekte durchsuchen")
        .sheet(isPresented: $projektManager.zeigeNeuesProjektDialog) {
            ProjektFormView(onSave: { neuesProjekt in
                projektManager.erstelleProjekt(projekt: neuesProjekt)
                projektManager.zeigeNeuesProjektDialog = false
            })
        }
        .sheet(isPresented: $projektManager.zeigePDFImportDialog) {
            PDFImportView()
        }
    }
}

struct DetailContainer: View {
    @EnvironmentObject var projektManager: ProjektManager
    
    var body: some View {
        VStack {
            if let projekt = projektManager.ausgewähltesProjekt {
                DetailView(projekt: projekt)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .id(projekt.id) // Wichtig für Animationen bei Projektwechsel
            } else {
                WillkommensView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: projektManager.ausgewähltesProjekt)
    }
}

struct WillkommensView: View {
    @EnvironmentObject var projektManager: ProjektManager
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("Willkommen bei FundingForce")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            
            Text("Starten Sie mit der Analyse und Kapitalbeschaffung für Ihre Projekte")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 16) {
                Button(action: {
                    projektManager.zeigeNeuesProjektDialog = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Neues Projekt erstellen")
                    }
                    .frame(width: 240)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    projektManager.zeigePDFImportDialog = true
                }) {
                    HStack {
                        Image(systemName: "doc.fill")
                        Text("Aus PDF importieren")
                    }
                    .frame(width: 240)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Features-Übersicht
            HStack(spacing: 30) {
                FeatureCard(
                    icon: "percent",
                    title: "Erfolgswahrscheinlichkeit",
                    description: "Berechnen Sie die Erfolgsaussichten Ihrer Projekte"
                )
                
                FeatureCard(
                    icon: "megaphone.fill",
                    title: "Marketinganalyse",
                    description: "Optimieren Sie Ihre Marketingkosten und -strategie"
                )
                
                FeatureCard(
                    icon: "chart.bar.fill",
                    title: "Visualisierung",
                    description: "Datenvisualisierung für bessere Entscheidungen"
                )
            }
            .padding(.bottom, 40)
        }
        .padding()
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(height: 40)
        }
        .frame(width: 180)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}
