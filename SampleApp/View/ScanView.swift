//
//  SwiftUIView.swift
//  
//
//  Created by Gabriel Souza on 29/05/22.
//

import SwiftUI
import RealityKit
import LidarProviders
import LidarViews

struct ScanView: View {
    let arProvider = LidarProviders.ARProvider()
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileName = "scan.dae"
    @State private var showingSheet = false
    
    #if DEBUG
    @EnvironmentObject var debugData: LidarProviders.DepthData
    
    @State private var showingDebugMetrics = false
    @State private var topRightCorner: Float32?
    @State private var topLeftCorner: Float32?
    @State private var center: Float32?
    @State private var bottomRightCorner: Float32?
    @State private var bottomLeftCorner: Float32?
    #endif
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottom) {
                #if DEBUG
                ARDepthView(
                        arProvider: self.arProvider
                ).environmentObject(debugData)
                #else
                ARDepthView(arProvider: arProvider)
                #endif
                HStack {
                    Button(action: {
                        EnvironmentVariables.shared.dispatchQueue.async {
                            let filePath: URL = self.documentsPath.appendingPathComponent(self.fileName)
                            let asset = self.arProvider.createModel()
                            asset.write(to: filePath, delegate: self.arProvider.arReceiver)
                            self.showingSheet = true
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                                .font(.title)
                                .foregroundColor(.white)
                    }
                            .sheet(
                                    isPresented: $showingSheet,
                                    content: {
                                        let filePath: URL = self.documentsPath.appendingPathComponent(self.fileName)
                                        LidarViews.ActivityView(activityItems: [filePath] as [Any], applicationActivities: nil)
                                    })
                            .padding()
                    #if DEBUG
                    Button(action: {
                        self.showingDebugMetrics.toggle()
                        self.arProvider.switchCaptureMetrics()
                    }) {
                        Image(systemName: "ladybug")
                                .font(.title)
                                .foregroundColor(.white)
                    }
                            .padding()
                    #endif
                }
                        .background(Color.gray.opacity(0.75))
                        .cornerRadius(10)
            }

            #if DEBUG
            if showingDebugMetrics {
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("Canto superior direito")
                            Text("Canto superior esquerdo:")
                            Text("Centro:")
                            Text("Canto inferior direito:")
                            Text("Canto inferior esquerdo:")
                        }
                        VStack(alignment: .leading) {
                            Text("\(self.topRightCorner ?? 0.0)")
                                    .onReceive(debugData.$topRightCorner) { newData in
                                        self.topRightCorner = newData
                                    }
                            Text("\(self.topLeftCorner ?? 0.0)")
                                    .onReceive(debugData.$topLeftCorner) { newData in
                                        self.topLeftCorner = newData
                                    }
                            Text("\(self.center ?? 0.0)")
                                    .onReceive(debugData.$center) { newData in
                                        self.center = newData
                                    }
                            Text("\(self.bottomRightCorner ?? 0.0)")
                                    .onReceive(debugData.$bottomRightCorner) { newData in
                                        self.bottomRightCorner = newData
                                    }
                            Text("\(self.bottomLeftCorner ?? 0.0)")
                                    .onReceive(debugData.$bottomLeftCorner) { newData in
                                        self.bottomLeftCorner = newData
                                    }
                        }
                    }
                            .foregroundColor(.white)
                            .padding()
                    Button(action: { self.arProvider.debugData?.capturingMetrics.toggle() }) {
                        HStack {
                            Image(systemName: "snowflake")
                                    .font(.body)
                            Text("Congelar métricas")
                                    .fontWeight(.semibold)
                                    .font(.body)
                        }
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.cyan)
                                .cornerRadius(40)
                    }
                            .padding()
                }
                        .background(Color.gray.opacity(0.75))
                        .cornerRadius(10)
            }
            #endif
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
