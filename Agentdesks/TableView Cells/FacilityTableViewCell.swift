//
//  FacilityTableViewCell.swift
//  Agentdesks
//
//  Created by Saurabh Gupta on 21/07/18.
//  Copyright © 2018 saurabh. All rights reserved.
//

import UIKit

class FacilityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var facilityImageView: UIImageView!
    @IBOutlet weak var facilityNameLabel: UILabel!
    @IBOutlet weak var gardenAreaImageView: UIImageView!
    @IBOutlet weak var garageImageView: UIImageView!
    @IBOutlet weak var swimmingPoolImageView: UIImageView!
    @IBOutlet weak var numberOfRoomsTextField: UITextField! {
        didSet {
            numberOfRoomsTextField.inputView = pickerView
            pickerView.delegate = self
            pickerView.dataSource = self
        }
    }
    
    let rooms = ["1", "2", "3"]
    var pickerView = UIPickerView()
}


extension FacilityTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rooms.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rooms[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numberOfRoomsTextField.text = rooms[row]
        numberOfRoomsTextField.resignFirstResponder()
    }
}
