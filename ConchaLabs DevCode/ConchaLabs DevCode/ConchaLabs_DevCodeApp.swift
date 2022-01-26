//
//  ConchaLabs_DevCodeApp.swift
//  ConchaLabs DevCode
//
//  Created by Dan Muana on 1/25/22.
//

import SwiftUI

@main
struct ConchaLabs_DevCodeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
