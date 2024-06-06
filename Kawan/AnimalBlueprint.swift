//
//  AnimalBlueprint.swift
//  Kawan
//
//  Created by Nicholas Christian Irawan on 05/06/24.
//

import SwiftUI

class AnimalBlueprint: ObservableObject {
    static let shared = AnimalBlueprint()
    
    struct animalSetting {
        var genus: String
        var diet: String
        var habitat: String
    }

    @Published var animalDict: [String: animalSetting] = [
        "Shiba": animalSetting(genus: "Dog", diet: "Carnivore", habitat: "Land"),
        "Cow": animalSetting(genus: "Cow", diet: "Herbivore", habitat: "Land")
    ]
}
