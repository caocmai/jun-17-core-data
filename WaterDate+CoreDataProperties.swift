//
//  WaterDate+CoreDataProperties.swift
//  plants
//
//  Created by Cao Mai on 6/17/20.
//  Copyright © 2020 Adriana González Martínez. All rights reserved.
//
//

import Foundation
import CoreData


extension WaterDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WaterDate> {
        return NSFetchRequest<WaterDate>(entityName: "WaterDate")
    }

    @NSManaged public var date: Date?
    @NSManaged public var plant: Plant?

}
