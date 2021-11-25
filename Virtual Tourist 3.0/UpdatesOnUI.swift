//
//  UpdatesOnUI.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import Foundation

// Perform the UI Updates on the main thread

func performUIUpdatesOnTheMainThread(_ updates: @escaping () -> Void){
    
    DispatchQueue.main.async {
        updates()
    }
}
