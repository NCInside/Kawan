//
//  Animal.swift
//  Kawan
//
//  Created by Nicholas Christian Irawan on 03/06/24.
//

import Foundation
import SwiftData

@Model
final class Animal: Identifiable {
    
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var genus: String
    var diet: String
    var habitat: String
    var status: String
    var happy: Int32
    var clean: Int32
    var hunger: Int32
    var date: Date
    
    init(id: String = UUID().uuidString, name: String, genus: String, diet: String, habitat: String, status: String, happy: Int32, clean: Int32, hunger: Int32, date: Date) {
        self.id = id
        self.name = name
        self.genus = genus
        self.diet = diet
        self.habitat = habitat
        self.status = status
        self.happy = happy
        self.clean = clean
        self.hunger = hunger
        self.date = date
    }
}
