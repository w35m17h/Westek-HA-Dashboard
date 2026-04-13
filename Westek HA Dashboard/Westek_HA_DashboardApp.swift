//
//  Westek_HA_DashboardApp.swift
//  Westek HA Dashboard
//
//  Created by William E Smith on 4/13/26.
//

import SwiftUI

@main
struct Westek_HA_DashboardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    for window in NSApplication.shared.windows {
                        window.level = .floating
                    }
                }
        }
    }
}
