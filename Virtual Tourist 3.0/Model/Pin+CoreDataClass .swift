//
//  Pin+CoreDataClass .swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import Foundation
import CoreData

// Class to represent the Pin object with a convenience init

public class Pin : NSManagedObject{
    
    
    // initializer to create instances of Pin, takes the data from the pin input
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        // check for the entity
        if let entity =  NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            // initialize an entity
            self.init(entity: entity, insertInto: context)
            
            // assing the longitude and latitude to the new entity
            self.latitude  = latitude
            self.longitude = longitude
            
        }
        // failure
        else {
            fatalError("Unable to find entity name - Case 'Pin' ")
        }
            
        
    }
}
