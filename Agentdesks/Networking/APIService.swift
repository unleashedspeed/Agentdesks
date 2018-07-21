//
//  APIService.swift
//  Agentdesks
//
//  Created by Saurabh Gupta on 21/07/18.
//  Copyright © 2018 saurabh. All rights reserved.
//

import Foundation
import Alamofire

class APIService {
    
    static let standard = APIService()
    
    private func request(url : String,
                         method: HTTPMethod,
                         parameters: [String: Any]?,
                         headers: HTTPHeaders?,
                         completionHandler: @escaping ([String: Any]? , Error?) -> Void) {
        let request = Alamofire.request(url, method: method, parameters: parameters, headers: headers).responseJSON { response in
            guard response.result.isSuccess else {
                completionHandler(nil, response.result.error)
                return
            }
            
            guard let value = response.result.value as? [String: Any] else {
                completionHandler(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Malformed data received"]))
                return
            }
            
            completionHandler(value, nil)
        }
        debugPrint(request)
    }
    
    func getFacilities(completionHandler: @escaping (([Facility]?, [[Exclusion]]?, Error?) -> Void)) {
        let url = "https://my-json-server.typicode.com/iranjith4/ad-assignment/db"
        var facilities: [Facility] = []
        var exclusions: [[Exclusion]] = []
        request(url: url,
                method: .get,
                parameters: nil,
                headers: nil) { [weak self]
                    (response, error) in
                    if let error = error {
                        completionHandler(nil, nil, error)
                        return
                    }
                    
                    if let values = response {
//                        Error handling should be present here for all the error codes designed by backend engineer for this Endpoint. One example is given below.
                        
//                        let status = value["status"] as! String
//                        let errorCode = value["error_code"] as! String
//                        if status == "failure" && errorCode == "1" {
//                            completionHandler(nil, NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid Request"]))
//
//                            return
//                        }
                        
                        do {
                            guard let facilitiesJSONObject = values["facilities"] as? [AnyObject], let exclusionsJSONObject = values["exclusions"] as? [[AnyObject]] else {
                                completionHandler(nil, nil, NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse data."]))
                                
                                return
                            }
                            
                            for facilityJSONObject in facilitiesJSONObject {
                                let data = try JSONSerialization.data(withJSONObject: facilityJSONObject as Any, options: .prettyPrinted)
                                let decoder = JSONDecoder()
                                let facility = try decoder.decode(Facility.self, from: data)
                                facilities.append(facility)
                            }
                            
                            for exclusionJSONObject in exclusionsJSONObject {
                                var elements: [Exclusion] = []
                                for element in exclusionJSONObject {
                                    let data = try JSONSerialization.data(withJSONObject: element as Any, options: .prettyPrinted)
                                    let decoder = JSONDecoder()
                                    let exclusion = try decoder.decode(Exclusion.self, from: data)
                                    elements.append(exclusion)
                                }
                                exclusions.append(elements)
                            }

                            
                            completionHandler(facilities, exclusions, nil)
                        } catch let error {
                            print("Err", error)
                            completionHandler(nil, nil, error)
                        }
                    }
        }
    }
}
