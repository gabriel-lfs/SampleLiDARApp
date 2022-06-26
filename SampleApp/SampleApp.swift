//
//  SampleAppApp.swift
//  SampleApp
//
//  Created by Gabriel Souza on 29/05/22.
//

import SwiftUI
import LidarProviders

@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            ScanView().environmentObject(LidarProviders.DepthData())
            #else
            ScanView()
            #endif
        }
    }
}
