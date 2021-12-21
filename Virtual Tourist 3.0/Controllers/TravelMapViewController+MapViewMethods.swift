//
//  TravelMapViewController+MapViewMethods.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 01/12/2021.
//

import Foundation
import MapKit
import CoreData

extension TravelMapViewController: MKMapViewDelegate{
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

            let reuseId = "pin"

            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.pinTintColor = .red
            }
            else {
                pinView!.annotation = annotation
            }


            return pinView
        }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print("didSelct HAS BEEN CALLED")
        
        let selectedCoordinate = view.annotation?.coordinate
        
        let latitude = selectedCoordinate?.latitude
        
        let longitude = selectedCoordinate?.longitude
        
        // edit mode is false, go to PhotosAlbumViewController
        if !editMode{
            
            // loop through the pins and go to PhotosAlbumViewController with the pin
            for pin in pins {
                
                // get the pin with the same location
                if pin.latitude == latitude && pin.longitude == longitude {
                    
                    // store the correct pinToPass
                    self.pinToBePassed = pin
                    
                    // store the coordinate of that pin
                    self.pinCoordinate = selectedCoordinate
                }
            }
            // go to PhotosAlbumViewController
            performSegue(withIdentifier: "GoToPhotosVC", sender: selectedCoordinate)
            
            // deselect the pin
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
        
        // edit mode is true, remove the pin from the view and core data
        else {
        
            // loop the pins and remove them
            for pin in pins {
                
                // get the pin with the same location
                if pin.latitude == latitude && pin.longitude == longitude {
                    
                    // create a pin to delete
                    let pinToBeDeleted = pin
                    
                    // use core data context to delete that pin
                    dataControllerClass.viewContext.delete(pinToBeDeleted)
                    
                    // save the changes
                    try? dataControllerClass.viewContext.save()
                }
            }
            
            // remove the pin from the map
            mapView.removeAnnotation(view.annotation!)
            
        }
    }
    
}
