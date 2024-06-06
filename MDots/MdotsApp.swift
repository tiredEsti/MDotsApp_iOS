//
//  MdotsApp.swift
//  Mdots
//
//  Created by Estela Alvarez on 7/11/23.
//

import SwiftUI
import Firebase

@main
struct MDotsApp: App {
    init(){
        FirebaseApp.configure()
        //let test = SensorController()
        //test.bleScan()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

