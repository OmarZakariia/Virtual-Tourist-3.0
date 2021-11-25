//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import Foundation
import CoreData

// Extension to store Photo properties and methods

extension Photo {
    
    // search for persistant instances of the object Photo
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }
    
    // Attributes
    
    @NSManaged public var imageData: NSData?
    @NSManaged public var imageURL: String?
    

    
    // Relationship

    @NSManaged public var pin: Pin?
}
