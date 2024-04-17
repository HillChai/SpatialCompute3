//
//  SnapshotView.swift
//  SnapshotInARView
//
//  Created by cccc on 2024/3/20.
//

import SwiftUI

struct SnapshotView: View {
    
    @State var showAlert: Bool = false
    @State var isPresent: Bool = false
    
    //ARView
    let customARView = ARViewContainer.instanceForSnapshot
    
    @AppStorage("isAutoFocus") var isAutoFocus = true
    
    var body: some View {
        
        ZStack  {
            
            SnapshotContainer.instance
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    
                    Image(systemName: "gearshape")
                        .resizable()
                        .foregroundStyle(Color.white)
                        .frame(width: 35, height: 35)
                        .padding()
                        .sheet(isPresented: $isPresent, content: {
                            BluetoothSettingsView()
                        })
                        .onTapGesture(perform: {
                            isPresent.toggle()
                        })
                    
                    Spacer()
                    
                    Button {
                        customARView.StartSession {
                        }
                        customARView.recordingTime = getFolderName()
                        createFolderIfNeeded(fileFolder: customARView.recordingTime)
                        showAlert.toggle()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .resizable()
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        return Alert(title: isAutoFocus ?
                                     Text("文件夹已创建🛎️,当前为自动对焦") :
                                        Text("文件夹已创建🛎️,当前为固定对焦"))
                    }
                }
                
                Spacer()
                
                Text(customARView.sessionInfolLabel)
                    .background(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                HStack {
                    
                    Button(action: {
                        if customARView.recordingTime != "" {
                            guard let path = getPathForJson(folderName: customARView.recordingTime, name: customARView.recordingTime) else { return }
                            do {
                                let bigData = try? JSONEncoder().encode(customARView.jsonObject)
                                try bigData?.write(to: path, options: [.atomic])
                                print("Json finished")
                                customARView.jsonObject.removeAll()
                            } catch let error {
                                print("Errors: \(error)")
                            }
                        }
                    }, label: {
                        Image(systemName: "square.and.arrow.down.fill")
                            .resizable()
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                    })
                    .padding()
                    
                    Button(action: {
                        customARView.snapFlag = true
                    }, label: {
                        Image(systemName: "camera.circle.fill")
                            .resizable()
                            .foregroundStyle(.white)
                            .frame(width: 55, height: 55)
                    })
                    .padding()
                    
                }
                
            }
            
        }
        
    }
}

#Preview {
    SnapshotView()
}
