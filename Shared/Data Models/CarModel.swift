//
//  CarModel.swift
//  F1 mac app
//
//  Created by Parineet Vernekar on 22/02/2022.
//

import Foundation

struct Car: Codable, Identifiable{
    var id = UUID()
    
    let name : String
    let info : String
    let maker : String
    let modelCredits : String
    let imageName : String
    let year : String
}


let cars = [
    Car(name: "RB16B", info: "Developed for the 2021 Formula 1 Season, the RB16B is the car that won Max Verstappen his first World Driver Championship and Oracle Red Bull Racing's first driver championship in 8 years. It provides 900HP of power, has an engine weight of 150kg and has a maximum rpm of 15000.", maker: "Oracle Red Bull Racing", modelCredits: "Developed by Jan Esch on Sketchfab. Allowed to reuse under Creative Commons license", imageName: "redbullcar", year: "2021"),
    Car(name: "MCL35M", info: "Developed for the 2021 Formula 1 Season, the MCL35M is a iteration of 2020s MCL35. It was driven by Mclaren drivers Daniel Riccardo and Lando Norris, and was the car that brought Mclaren to 4th place in the 2021 World Constructor's Championship", maker: "Mclaren F1 Team", modelCredits: "Developed by TheoDev on SketchFab. Allowed to reuse under Creative Commons License", imageName: "mclarencar", year: "2021"),
    Car(name: "2022 FIA Car", info: "Made by the FIA to give race teams an idea and a basis for their 2022 cars, featuring completely new regulations and chassis design", maker: "FIA", modelCredits: "Developed by TheoDev on SketchFab. Allowed to reuse under Creative Commons License", imageName: "f1generic", year: "2022")
]
