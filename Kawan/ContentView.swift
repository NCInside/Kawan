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
    @State private var deleteOldAnimal = false
    @ObservedObject var recogd: ModelRecognizer = .shared
    @Environment(\.presentationMode) var presentationMode
    
    var isFed: Bool {
        return recogd.feedMeat || recogd.feedVeg
    }
    
    var body: some View {
        TameView(modelName: modelName, recogd: recogd, deleteOldAnimal: $deleteOldAnimal)
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: .constant(isFed), content: {
                SheetView(modelName: modelName)
            })
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        deleteOldAnimal = true
                        
                    }) {
                        Image(systemName: "figure.run")
                            .imageScale(.large)
                            .foregroundStyle(.white)
                    }
                }
            }
    }
}

struct SheetView: View {
    var modelName: String?
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject var animalBlueprint: AnimalBlueprint
    @State private var nickname = ""
    private let status = "Wild"
    
    private var animalSetting: AnimalBlueprint.animalSetting? {
        guard let modelName = modelName else { return nil }
        let key = modelName.replacingOccurrences(of: ".usdz", with: "")
        return animalBlueprint.animalDict[key]
    }

    var body: some View {
        VStack {
            Text("Congratulations!")
                .font(.system(.largeTitle, weight: .bold))
                .padding(.top, 5)
            Text("You caught a " + animalSetting!.genus)
                .font(.system(.title, weight: .medium))
            Animal3DNonInteractable(modelName: modelName!)
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
                    Text(animalSetting!.diet)
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
                    Text(status)
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
                    Text(animalSetting!.habitat)
                        .foregroundStyle(.white)
                        .font(.system(.subheadline, weight: .bold))
                }
                .padding()
                .background(Color(red: 160/255, green: 193/255, blue: 114/255))
                .cornerRadius(10)
            }
            .padding(.vertical)
            Button("DONE") {
                let animal = Animal(name: nickname, genus: animalSetting!.genus, diet: animalSetting!.diet, habitat: animalSetting!.habitat, status: status, happy: 0, clean: 0, hunger: 0, date: Date.now)
                context.insert(animal)
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            .foregroundStyle(.white)
            .font(.system(.largeTitle, weight: .bold))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(red: 160/255, green: 193/255, blue: 114/255))
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(red: 142/255, green: 177/255, blue: 92/255), lineWidth: 2))
        }
        .onAppear {
            print("Sheet")
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
    ContentView(modelName: "Shiba.usdz")
}
