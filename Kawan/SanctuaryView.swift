//
//  SanctuaryView.swift
//  Kawan
//
//  Created by Nicholas Christian Irawan on 03/06/24.
//

import SwiftUI
import SwiftData

struct SanctuaryView: View {
    @Environment(\.modelContext) private var context
    @State private var goToAnimal = false
    @Query(sort: \Animal.date, order: .reverse) private var animals: [Animal]
    private let flexibleColumn = [
        GridItem(.flexible(minimum: 100, maximum: 200)),
        GridItem(.flexible(minimum: 100, maximum: 200)),
    ]
    
    var body: some View {
        ZStack {
            Color(red: 160/255, green: 193/255, blue: 114/255)
                .ignoresSafeArea()
            VStack {
                Text("Sanctuary")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                LazyVGrid(columns: flexibleColumn, spacing: 20) {
                    ForEach(animals, id: \.id) { animal in
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(.white, lineWidth: 6)
                                    .fill(Color(red: 177/255, green: 207/255, blue: 134/255))
                                    .padding(10)
                                SceneKitView(modelName: animal.genus + ".usdz", navigateToContentView: $goToAnimal)
                                    .frame(width: 180, height: 180)
                            }
                            Text(animal.name)
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SanctuaryView()
        .modelContainer(previewContainer)
}

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: Animal.self,configurations: .init(isStoredInMemoryOnly: true))

        for _ in 1...15 {
            container.mainContext.insert(generateRandomAnimal())
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

func generateRandomAnimal() -> Animal {
    return Animal(name: "Bruh", genus: "Shiba", diet: "Carnivore", habitat: "Land", status: "Domesticated", happy: 30, clean: 30, hunger: 30, date: Date.now)
}

func createAnimal(context: ModelContext) -> Void {
    for _ in 1...15 {
        let animal = generateRandomAnimal()
        context.insert(animal)
    }
    do {
        try context.save()
    } catch {
        print(error.localizedDescription)
    }
}
