//
//  Facility.swift
//  Agentdesks
//
//  Created by Saurabh Gupta on 21/07/18.
//  Copyright © 2018 saurabh. All rights reserved.
//

import Foundation

struct Facility : Codable {
    let id: String?
    let name: String?
    let options: [Option]?
    
    enum CodingKeys: String, CodingKey {
        case id = "facility_id"
        case name = "name"
        case options
    }
    
    struct Option: Codable {
        let name: String?
        let icon: String?
        let id: String?
    }
}


