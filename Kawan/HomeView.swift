//
//  HomeView.swift
//  Kawan
//
//  Created by Nicholas Christian Irawan on 28/05/24.
//

import SwiftUI
import SceneKit

struct HomeView: View {
    @EnvironmentObject var animalBlueprint: AnimalBlueprint
    @State private var isExpand = false
    @State private var goToAnimal = false
    @State private var positions: [HashablePoint] = []
    @State private var selectedModelName: String?
        
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 160/255, green: 193/255, blue: 114/255)
                    .ignoresSafeArea()
                Circle()
                    .stroke(.white, lineWidth: 6)
                    .fill(Color(red: 177/255, green: 207/255, blue: 134/255))
                    .frame(width: 350)
                    .overlay(
                        ForEach(positions, id: \.self) { position in
                            Animal3DInteractable(modelName: animalBlueprint.animalDict.keys.randomElement()! + ".usdz", navigateToContentView: $goToAnimal, selectedModelName: $selectedModelName)
                                .frame(width: 120, height: 120)
                                .position(position.point)
                        }
                    )
                    .offset(y: -50)
                if isExpand {
                    Color(red: 0/255, green: 0/255, blue: 0/255)
                        .ignoresSafeArea()
                        .opacity(0.5)
                }
                HomeButton(destination: SanctuaryView(), buttonLabel: "Inventory", buttonSymbol: "archivebox", xMove: 45, yMove: 160, isExpand: $isExpand)
                HomeButton(destination: SanctuaryView(), buttonLabel: "Shop", buttonSymbol: "bag", xMove: 110, yMove: 250, isExpand: $isExpand)
                HomeButton(destination: SanctuaryView(), buttonLabel: "Minigame", buttonSymbol: "gamecontroller", xMove: -45, yMove: 160, isExpand: $isExpand)
                HomeButton(destination: SanctuaryView(), buttonLabel: "Sanctuary", buttonSymbol: "map", xMove: -110, yMove: 250, isExpand: $isExpand)
                Button(action: {self.isExpand.toggle()}) {
                    Label("Center", systemImage: "plus.circle.fill")
                    .font(.system(size: 64))
                }
                .labelStyle(.iconOnly)
                .rotationEffect(isExpand ? .degrees(45) : .degrees(0))
                .foregroundColor(.white)
                .offset(y: 300)
                .animation(.easeInOut)
            }
            .overlay(NavigationLink(
                destination: ContentView(modelName: selectedModelName),
                isActive: $goToAnimal) {EmptyView()})
        }
        .onAppear {
            generatePositions()
        }
    }
    
    func generatePositions() {
        for _ in 0..<3 {
            let position = CGPoint(x: CGFloat.random(in: 0...350), y: CGFloat.random(in: 0...350))
            positions.append(HashablePoint(point: position))
        }
    }
}

struct HomeButton<Destination: View>: View {
    var destination: Destination
    var buttonLabel: String
    var buttonSymbol: String
    var xMove: Int
    var yMove: Int
    @Binding var isExpand: Bool
    
    @State private var goToView = false
    
    var body: some View {
        VStack {
            NavigationLink(destination: destination, isActive: $goToView) { EmptyView() }
            Button(action: {self.goToView.toggle()}) {
                Label(buttonLabel, systemImage: buttonSymbol)
                    .font(.system(size: 40))
            }
            .padding(12)
            .labelStyle(.iconOnly)
            .background(Color.white)
            .foregroundColor(Color(red: 142/255, green: 177/255, blue: 92/255))
            .clipShape(Circle())
            Text(buttonLabel)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
        }
        .offset(x: isExpand ? CGFloat(xMove): 0, y: isExpand ? CGFloat(yMove) : 300)
        .opacity(isExpand ? 1 : 0)
        .animation(.easeInOut)
    }
}

struct Animal3DInteractable: UIViewRepresentable {
    var modelName: String
    @Binding var navigateToContentView: Bool
    @Binding var selectedModelName: String?

    class Coordinator: NSObject {
        var parent: Animal3DInteractable

        init(parent: Animal3DInteractable) {
            self.parent = parent
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            parent.selectedModelName = parent.modelName
            parent.navigateToContentView = true
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = SCNScene(named: modelName)
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = .clear
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
                scnView.addGestureRecognizer(tapGestureRecognizer)
        
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}

struct HashablePoint: Hashable {
    let point: CGPoint

    static func == (lhs: HashablePoint, rhs: HashablePoint) -> Bool {
        return lhs.point == rhs.point
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(point.x)
        hasher.combine(point.y)
    }
}

#Preview {
    HomeView()
        .environmentObject(AnimalBlueprint.shared)
}
