//
//  ViewController.swift
//  Agentdesks
//
//  Created by Saurabh Gupta on 21/07/18.
//  Copyright © 2018 saurabh. All rights reserved.
//

import UIKit
import CoreData

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
    
    var exclusions: [[NSManagedObject]]?
    var facilities: [NSManagedObject] = []
    let cellIdentifier = "FacilityCell"
    var selectedIndexPath = IndexPath()
    var loadingDataFromAPI = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Properties", comment: "Properties Title")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Property")
        do {
            facilities = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if let date = UserDefaults.standard.object(forKey: "lastLocalStorageUpdate") as? Date {
            if let difference = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour, difference >= 24 {
                loadDataFromAPI()
                loadingDataFromAPI = true
            }
        }
        
        if facilities.count == 0 && !loadingDataFromAPI {
            loadDataFromAPI()
        }
    }
    
    func loadDataFromAPI() {
        APIService.standard.getFacilities { (facilities, exclusions, error) in
            if error == nil {
                guard let facilities = facilities, let exclusions = exclusions else { return }
                self.updateLocalStorage(with: facilities)
                self.updateLocalStorage(with: exclusions)
                UserDefaults.standard.set(Date(), forKey:"lastLocalStorageUpdate")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.loadingDataFromAPI = false
                }
            } else {
                self.loadingDataFromAPI = false
                // Do appropriate error handling here. May be show an alert.
            }
        }
    }
    
    func updateLocalStorage(with facilties: [Facility]) {
        self.facilities.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Property")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
        for facilty in facilties {
            let entity = NSEntityDescription.entity(forEntityName: "Property", in: managedContext)!
            let facilityManagedObject = NSManagedObject(entity: entity, insertInto: managedContext)
            facilityManagedObject.setValue(facilty.id, forKey: "id")
            facilityManagedObject.setValue(facilty.name, forKey: "name")
            let optionsSet = facilityManagedObject.mutableSetValue(forKey: "options")
            
            if let options = facilty.options {
                for option in options {
                    if let optionObject = createRecordForEntity("PropertyOption", inManagedObjectContext: managedContext) {
                        optionObject.setValue(option.id, forKey: "id")
                        optionObject.setValue(option.icon, forKey: "icon")
                        optionObject.setValue(option.name, forKey: "name")
                
                        optionsSet.add(optionObject)
                    }
                }
            }
            
            do {
                try managedContext.save()
                self.facilities.append(facilityManagedObject)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                // Do appropriate error handling here. May be show an alert.
            }
        }
    }
    
    func updateLocalStorage(with exclusions: [[Exclusion]]) {
        self.exclusions?.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExclusionEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
        
        for exclusion in exclusions {
            var exclusionList: [NSManagedObject] = []
            for element in exclusion {
                let entity = NSEntityDescription.entity(forEntityName: "ExclusionEntity", in: managedContext)!
                let exclusionManagedObject = NSManagedObject(entity: entity, insertInto: managedContext)
                exclusionManagedObject.setValue(element.optionsID, forKey: "optionsID")
                exclusionManagedObject.setValue(element.facilityID, forKey: "facilityID")
                
                do {
                    try managedContext.save()
                    exclusionList.append(exclusionManagedObject)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    // Do appropriate error handling here. May be show an alert.
                }
            }
            
            self.exclusions?.append(exclusionList)
        }
    }
    
    private func createRecordForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
        var result: NSManagedObject?
        
        let entityDescription = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)
        if let entityDescription = entityDescription {
            result = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
        }
        
        return result
    }
}

extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return facilities.first?.mutableSetValue(forKey: "options").count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FacilityTableViewCell
        let options = facilities.first?.mutableSetValue(forKey: "options")
        let facility = (options?.allObjects as? [PropertyOption])?[indexPath.row]
        cell.facilityNameLabel.text = facility?.name
        cell.facilityImageView.image = UIImage(named: facility?.icon ?? "")
        
        if let index = facilities.index(where: { $0.value(forKey: "name") as? String == "Other facilities" }) {
            let otherFacilities = facilities[index].mutableSetValue(forKey: "options").allObjects as? [PropertyOption]
            if otherFacilities?.count ?? 0 >= 3 {
                cell.swimmingPoolImageView.image = UIImage(named: otherFacilities?.first?.icon ?? "")
                cell.gardenAreaImageView.image = UIImage(named: otherFacilities?[1].icon ?? "")
                cell.garageImageView.image = UIImage(named: otherFacilities?[2].icon ?? "")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath.count > 0 {
            let cellToUncheck = tableView.cellForRow(at: selectedIndexPath)
            cellToUncheck?.accessoryType = .none
        }
        
        let cellToCheck = tableView.cellForRow(at: indexPath)
        cellToCheck?.accessoryType = .checkmark
        selectedIndexPath = indexPath
    }
}



