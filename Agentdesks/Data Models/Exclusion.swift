//
//  Exclusion.swift
//  Agentdesks
//
//  Created by Saurabh Gupta on 21/07/18.
//  Copyright © 2018 saurabh. All rights reserved.
//

import Foundation

struct Exclusion : Codable {
    let facilityID: String?
    let optionsID: String?
    
    enum CodingKeys: String, CodingKey {
        case facilityID = "facility_id"
        case optionsID = "options_id"
    }
}
