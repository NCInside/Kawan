//
//  ContentView.swift
//  Kawan
//
//  Created by Nicholas Christian Irawan on 28/05/24.
//

import SwiftUI
import Photos
import RealityKit
import SceneKit

struct ContentView : View {
    var modelName: String?
    @State private var isCaptured = false
    
    var body: some View {
        TameView(modelName: modelName)
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: $isCaptured, content: {
                SheetView()
            })
    }
}

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var nickname = ""

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {dismiss()}) {
                    Label("Close", systemImage: "xmark")
                        .font(.system(size: 32))
                }
                .padding(.horizontal, 20)
                .foregroundStyle(.black)
                .labelStyle(.iconOnly)
            }
            Text("Congratulations!")
                .font(.system(.largeTitle, weight: .bold))
                .padding(.top, 5)
            Text("You caught a dog")
                .font(.system(.title, weight: .medium))
            Animal3DNonInteractable(modelName: "Shiba.usdz")
                .frame(width: 300, height: 300)
            TextField("Nickname", text: $nickname)
                .padding()
                .background(Color(red: 160/255, green: 193/255, blue: 114/255))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 142/255, green: 177/255, blue: 92/255), lineWidth: 2))
                .padding(.horizontal)
            HStack {
                VStack {
                    Text("Diet")
                        .padding(.horizontal)
                        .background(Color(red: 177/255, green: 207/255, blue: 134/255))
                        .foregroundStyle(.white)
                        .font(.system(.headline, weight: .bold))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("Carnivore")
                        .foregroundStyle(.white)
                        .font(.system(.subheadline, weight: .bold))
                }
                .padding()
                .background(Color(red: 160/255, green: 193/255, blue: 114/255))
                .cornerRadius(10)
                VStack {
                    Text("Status")
                        .padding(.horizontal)
                        .background(Color(red: 177/255, green: 207/255, blue: 134/255))
                        .foregroundStyle(.white)
                        .font(.system(.headline, weight: .bold))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("Domesticated")
                        .foregroundStyle(.white)
                        .font(.system(.subheadline, weight: .bold))
                }
                .padding()
                .background(Color(red: 160/255, green: 193/255, blue: 114/255))
                .cornerRadius(10)
                VStack {
                    Text("Habitat")
                        .padding(.horizontal)
                        .background(Color(red: 177/255, green: 207/255, blue: 134/255))
                        .foregroundStyle(.white)
                        .font(.system(.headline, weight: .bold))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("Urban")
                        .foregroundStyle(.white)
                        .font(.system(.subheadline, weight: .bold))
                }
                .padding()
                .background(Color(red: 160/255, green: 193/255, blue: 114/255))
                .cornerRadius(10)
            }
            .padding(.vertical)
            Button("DONE") {
                dismiss()
            }
            .foregroundStyle(.white)
            .font(.system(.largeTitle, weight: .bold))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(red: 160/255, green: 193/255, blue: 114/255))
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(red: 142/255, green: 177/255, blue: 92/255), lineWidth: 2))
        }
    }
}

struct Animal3DNonInteractable: UIViewRepresentable {
    var modelName: String
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = SCNScene(named: modelName)
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = .clear
                
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}

#Preview {
    ContentView()
}
