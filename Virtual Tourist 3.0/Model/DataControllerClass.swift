//
//  DataControllerClass.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import Foundation
import CoreData


class DataControllerClass {
    
    // peristent container
    let persistentContainer : NSPersistentContainer
    
    // view context
    var viewContext : NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // iniatilize a persistentContainer with the model name
    init (modelName : String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // load the persistent store
    func load(completion : (()-> Void)? = nil){
        persistentContainer.loadPersistentStores { storeDescription , error in
            
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
}

// MARK: - DataControllerClass Extension
extension DataControllerClass {
    
    func autoSaveViewContext(interval : TimeInterval = 30){
    // check for changes every 30 seconds, and if there are changes, save them
        guard interval > 0 else {
            print("Cant save in negative interval")
            return
        }
        
        // if there are changes in the viewcontext then save
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        // dispatch asyncAfter
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
        
        // test
        print("autosaving in progress")
    
        
        
    }
}
