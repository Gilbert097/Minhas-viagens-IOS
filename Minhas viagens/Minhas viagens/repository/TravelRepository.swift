//
//  TravelRepository.swift
//  Minhas viagens
//
//  Created by Gilberto Silva on 15/02/21.
//

import Foundation

class TravelRepository{
    static let shared = TravelRepository()
    private init() { }
    
    func getAll() -> [Travel]{
        do {
            if let travelRecovered = UserDefaults.standard.value(forKey: TravelParameter.travels.rawValue) as? Data {
                let decoder = JSONDecoder()
                let travelDecoded = try decoder.decode(Array.self, from: travelRecovered) as [Travel]
                return travelDecoded
            }
        } catch let error {
            print(error.localizedDescription)
            return [Travel]()
        }
        return [Travel]()
    }
    
    func save(travel: Travel) -> Bool {
        do {
            var travels = getAll()
            travels.append(travel)
            try persistTravels(travels)
        } catch let error {
            print(error.localizedDescription)
            return false
        }
        
        return true
    }
    
    func delete(travel: Travel)->Bool{
        var travels = getAll()
        let travelElement  = travels.enumerated().filter { (item) -> Bool in
            item.element.id == travel.id
        }.first
        
        if let travelRemove = travelElement {
            do {
                travels.remove(at: travelRemove.offset)
                try persistTravels(travels)
            } catch let error {
                print(error.localizedDescription)
                return false
            }
        }else{
            return false
        }
        return true
    }
    
    private func persistTravels(_ travels: [Travel]) throws {
        let encoder = JSONEncoder()
        let travelsEncoded = try encoder.encode(travels)
        UserDefaults.standard.set(travelsEncoded, forKey: TravelParameter.travels.rawValue)
    }
    
}
