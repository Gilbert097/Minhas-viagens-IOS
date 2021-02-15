//
//  Travel.swift
//  Minhas viagens
//
//  Created by Gilberto Silva on 15/02/21.
//

import Foundation

class Travel: Codable{
    var id:String
    var title:String
    
    init(title:String){
        self.id = UUID().uuidString
        self.title = title
    }
}
