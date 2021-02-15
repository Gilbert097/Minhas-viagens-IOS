//
//  LocationAddress.swift
//  Minhas viagens
//
//  Created by Gilberto Silva on 15/02/21.
//

import Foundation

class Address {
    var name = ""
    var thoroughfare =  ""
    var subThoroughfare = ""
    var locality = ""
    var subLocality =  ""
    var postalCode =  ""
    var country =  ""
    var administrativeArea =  ""
    var subAdministrativeArea =  ""
    
    init(name:String = "",
         thoroughfare:String = "",
         subThoroughfare:String = "",
         locality:String = "",
         subLocality :String = "",
         postalCode:String = "",
         country:String = "",
         administrativeArea:String = "",
         subAdministrativeArea:String = "") {
        self.name = name
        self.thoroughfare = thoroughfare
        self.subThoroughfare = subThoroughfare
        self.locality = locality
        self.subLocality = subLocality
        self.postalCode = postalCode
        self.country = country
        self.administrativeArea = administrativeArea
        self.subAdministrativeArea = subAdministrativeArea
    }
    
    func getShortAddress() -> String {
        "\(thoroughfare) - \(subThoroughfare) / \(locality) / \(country)"
    }
    
    func toString()->String{
            "\n name: \(name)" +
            "\n thoroughfare: \(thoroughfare)" +
            "\n subThoroughfare: \(subThoroughfare)" +
            "\n locality: \(locality)" +
            "\n subLocality: \(subLocality)" +
            "\n postalCode: \(postalCode)" +
            "\n country: \(country)" +
            "\n administrativeArea: \(administrativeArea)" +
            "\n subAdministrativeArea: \(subAdministrativeArea)"
    }
}
