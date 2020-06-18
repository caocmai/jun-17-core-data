//
//  ViewController.swift
//  plants
//
//  Created by Adriana González Martínez on 4/21/19.
//  Copyright © 2019 Adriana González Martínez. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    
    var managedContext: NSManagedObjectContext!
    var mainPlant : Plant?
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var dates: [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Water log"
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        //we will look for Cactus for this example. We'll go over how to query in future lessons.
        
        let plantSpecies = "Cactus"
        let plantSearch: NSFetchRequest<Plant> = Plant.fetchRequest()
        plantSearch.predicate = NSPredicate(format: "%K == %@", #keyPath(Plant.species), plantSpecies)
        
        do {
            let results = try managedContext.fetch(plantSearch)
            if results.count > 0 {
                // cactus found
                mainPlant = results.first
            } else {
                // not found, create cactus
                mainPlant = Plant(context: managedContext)
                mainPlant?.species = plantSpecies
                try managedContext.save()
            }
        } catch let error as NSError {
            print("Error: \(error) description: \(error.userInfo)")
        }
        
    }
    
    @IBAction func addLog(_ sender: Any) {
        //       dates.append(Date())
        
        //new water date entity
        let waterDate = WaterDate(context: managedContext)
        waterDate.date = NSDate() as Date
        
        //add it to the Plant's dates set
        
        if let plant = mainPlant, let dates = plant.waterDates?.mutableCopy() as? NSMutableOrderedSet {
            dates.add(waterDate)
            plant.waterDates = dates
        }
        
        //save the managed object context
        do {
            try self.managedContext.save()
            self.table.reloadData()
        } catch let error as NSError {
            print("Error: \(error), description: \(error.userInfo)")
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (mainPlant?.waterDates?.count)!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let waterDatesNSSet =  mainPlant!.waterDates
        let waterDateObject = waterDatesNSSet![indexPath.row] as! WaterDate
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dateFormatter.string(from: waterDateObject.date!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let date = mainPlant!.waterDates![indexPath.row] as! WaterDate
            do {
                self.mainPlant!.waterDates!.removeObject(at: indexPath.row)
                self.managedContext.delete(date)
                self.table.deleteRows(at: [indexPath], with: .fade)
                try self.managedContext.save()
            } catch {
                print(error)
            }
        }
    }
}

