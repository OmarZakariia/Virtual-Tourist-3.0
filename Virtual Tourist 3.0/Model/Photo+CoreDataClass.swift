//
//  Photo+CoreDataClass.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import Foundation
import CoreData

// Class to represent the Photo object with a convenience init

public class Photo : NSManagedObject{
    
//    initializer to create instances of Photos
    convenience init(imageURL: String?, context : NSManagedObjectContext) {
        
        // check for entity
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context){
            
            // create the entity
            self.init(entity: entity, insertInto: context)
            
            // assign the imageURL
            self.imageURL = imageURL
        }
        
        // failure
        else {
            fatalError("Failed to find entity - Case 'Photo' ")
        }
            
        
        
    }
}
