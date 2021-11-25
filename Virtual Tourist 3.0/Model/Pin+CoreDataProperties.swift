//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import Foundation
import CoreData

// Extension for Pin class with properties and functions

extension Pin {
    
    // search for persistant instances of the object Pin
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }
    
    // Attributes
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    
    
    // Relationships
    @NSManaged public var photos: NSSet?
}

extension Pin {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
