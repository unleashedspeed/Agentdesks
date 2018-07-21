//
//  ViewController.swift
//  Agentdesks
//
//  Created by Saurabh Gupta on 21/07/18.
//  Copyright © 2018 saurabh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.estimatedRowHeight = 44
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.register(FacilityTableViewCell.nib(), forCellReuseIdentifier: cellIdentifier)
            tableView.tableFooterView = UIView()
        }
    }
    
    var exclusions: [[Exclusion]]?
    var facilities: [Facility]?
    let cellIdentifier = "FacilityCell"
    var selectedIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIService.standard.getFacilities { (facilities, exclusions, error) in
            if error == nil {
                self.facilities = facilities
                self.exclusions = exclusions
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

}

extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return facilities?.first?.options?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FacilityTableViewCell
        let facility = facilities?.first?.options?[indexPath.row]
        let otherFacilities = facilities?[2].options
        let optionID = facility?.id
        var facilityIDsToExclude: [String] = []
        var optionIDsToExclude: [String] = []
        for exclusion in exclusions! {
            if exclusion.first?.optionsID == optionID {
                facilityIDsToExclude.append(exclusion[1].facilityID ?? "")
                optionIDsToExclude.append(exclusion[1].optionsID ?? "")
            }
        }
        cell.facilityNameLabel.text = facility?.name
        cell.facilityImageView.image = UIImage(named: facility?.icon ?? "")
        let optionsToExclude = otherFacilities?.filter( { optionIDsToExclude.contains($0.id ?? "")})
        cell.swimmingPoolImageView.image = UIImage(named: otherFacilities?.first?.icon ?? "")
        cell.gardenAreaImageView.image = UIImage(named: otherFacilities?[1].icon ?? "")
        cell.garageImageView.image = UIImage(named: otherFacilities?[2].icon ?? "")
        
        if selectedIndexPath == indexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if selectedIndexPath.count > 0 {
            let cellToUncheck = tableView.cellForRow(at: selectedIndexPath)
            cellToUncheck?.accessoryType = .none
        }
        
        let cellToCheck = tableView.cellForRow(at: indexPath)
        cellToCheck?.accessoryType = .checkmark
        selectedIndexPath = indexPath
    }
}



