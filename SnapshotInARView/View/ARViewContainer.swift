//
//  ARViewContainer.swift
//  SnapshotInARView
//
//  Created by cccc on 2024/3/20.
//

import SwiftUI

struct ARViewContainer {
    static var instanceForSnapshot = CustomARViewModel()
}

struct SnapshotContainer: UIViewRepresentable {
    
    static var instance = SnapshotContainer()
    
    func makeUIView(context: Context) -> some UIView {
        let arView = ARViewContainer.instanceForSnapshot
//        arView.debugOptions = [.showFeaturePoints]
            
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
}
