//
//  FundingForce_01App.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI

@main
struct FundingForce_01App: App {
    @StateObject private var projektManager = ProjektManager()
    @State private var showingSplash = true
    
    var body: some Scene {
        WindowGroup {
            if showingSplash {
                SplashScreen()
                    .onAppear {
                        // Zeige Splash für 2 Sekunden
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showingSplash = false
                            }
                        }
                    }
            } else {
                ContentView()
                    .environmentObject(projektManager)
                    .preferredColorScheme(.light) // Light-Mode als Standard
                    .frame(minWidth: 1024, minHeight: 768)
                    .onAppear {
                        // Fensterstil anpassen
                        for window in NSApplication.shared.windows {
                            window.titlebarAppearsTransparent = true
                            window.titleVisibility = .hidden
                        }
                    }
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            // Menü-Einträge
            CommandMenu("Projekt") {
                Button("Neues Projekt") {
                    projektManager.zeigeNeuesProjektDialog = true
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("Projekt importieren") {
                    projektManager.zeigePDFImportDialog = true
                }
                .keyboardShortcut("i", modifiers: .command)
                
                Divider()
                
                Button("Projekt exportieren") {
                    // Export-Funktion
                }
                .keyboardShortcut("e", modifiers: .command)
                .disabled(projektManager.ausgewähltesProjekt == nil)
            }
        }
    }
}

struct SplashScreen: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("FundingForce")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                
                Text("Kapital-Beschaffung leicht gemacht")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}
