//
//  TravelMapViewController.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import UIKit
import MapKit
import CoreData

class TravelMapViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate {

    /*
     Class to show the MapView and enable user to add/remove pins

     */


    // MARK: - IBOutlet/

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var deletePinsMessage: UIView!

    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    


    // MARK: - Properties

    // CoreData
    var dataControllerClass : DataControllerClass!

    // edit mode on the map
    var editMode : Bool = false

    // array of persistent pins
    var pins : [Pin] = []

    // pins that (added to the map) become annotations on the map
    var pinsOnMap : [PinsOnMap] = []

    // pin that will be passed onto the PhotoAlbumVC
    var pinToBePassed : Pin? = nil
    
    // coordinate of the pin to be passed
    var pinCoordinate : CLLocationCoordinate2D? = nil

    // array of flickerImages that are downloaded
    var flickrImages : [FlickrImage] = [FlickrImage]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // call editButton
        setupForEditDoneButton()
        
        // call function responsible fore longTapGesture setup
        setupLongTapGesture()
        
        // call the fetch request for pins
        fetchRequestForPins()
        
        print("view has loaded")
     
    }

    // MARK: - Functions


    func setupForEditDoneButton() {
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func fetchRequestForPins() {

        // are there any persisted pins objects ?
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()

        // check for the search results
        if let result = try? dataControllerClass.viewContext.fetch(fetchRequest) {

            // assign the persistent pins to the persistentpins array if there are any results
            pins = result
        }

        // iterate the array of pins and set the coordinate accordingly
        for pin in pins {
            // set the coordinate
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)

            // Convert the pins to adopt MKAannotation protocol
            let pins = PinsOnMap(coordinate: coordinate)

            // add the new pins to the pinsOnMap array
            pinsOnMap.append(pins)
        }
        // add the new pins to the mapView
        mapView.addAnnotations(pinsOnMap)

    }
    
    
    
 
    
    fileprivate func initiatePhotosAlbumViewController() {
        /*
         I need to pass 4 things
         1. data Controller
         2. pin
         3. coordinate
         4. flickerImages
         */
        
        
        // move to PhotosAlbumViewController
        let photosAlbumVC = PhotosAlbumViewController()
        
        // pass the dataController
        photosAlbumVC.dataControllerClass = dataControllerClass
        
        // pass the pin
        photosAlbumVC.pin = pinToBePassed
        
        // pass the coordinate
        
        // pass the images
        photosAlbumVC.flickerPhotos = flickrImages
    }
    
    @IBAction func addPinToMapUILongTapGesture(_ sender: UILongPressGestureRecognizer) {
        print("a long tap gesture has been recognized")
        
        // check that I am not in edit mode
        let state = sender.state
        
        switch state {
            
        case .ended:
            
            if !editMode{
                
                // create and drop the pins on the map
                addPinsToMap(sender: sender)

            }
        default:
            break
        }
    }
    
    func addPinsToMap( sender: UILongPressGestureRecognizer){
        // coordinates tapped on the map
        let longTapGestureLocation : CGPoint = sender.location(in: self.mapView)
        
        // get the coordinate where the user tapped the pin
        let coordinateTouched : CLLocationCoordinate2D = mapView.convert(longTapGestureLocation, toCoordinateFrom: mapView)
        
        // create an annotation of type MKPointAnnotation to add on the mapview
        let annotation : MKPointAnnotation = MKPointAnnotation()
        
        // add the coordinateTouched to the annotations' coordinate
        annotation.coordinate = coordinateTouched
        
        // add the pin to mapView
        mapView.addAnnotation(annotation)
        
        // add the pin  to the core data
        addPinToCoreData(coordiante: coordinateTouched)
        
        // request the photos from the pin coordinates
        requestFlickrPhotosFromPin(coordinate: coordinateTouched)
        
    }
    
    func requestFlickrPhotosFromPin(coordinate: CLLocationCoordinate2D){
        FlickrClient.sharedInstance().getPhotosPath(lat: coordinate.latitude, lon: coordinate.longitude) { photos, error in
            
            // check that the request was successful
            if let photos = photos {
                
                // store the photos in the 'photos' object
                self.flickrImages = photos
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "GoToPhotosVC", sender: coordinate)
                }
                
                // else an error occured
            } else {
                print( error ?? "empty error from requestFlickrPhotosFromPin ")
            }
        }
        print("\(flickrImages) flickrImages from  requestFlickrPhotosFromPin")
    }
    
    func addPinToCoreData(coordiante : CLLocationCoordinate2D){
        // Purpose of CoreData is to create and store pins
        
        // Create a pin object to store the pin
        let pin = Pin(latitude: coordiante.latitude, longitude: coordiante.longitude, context: dataControllerClass.viewContext)
        
        // append the pin to the array containing the persisted pins
        pins.append(pin)
        
        // save the changes
        try? dataControllerClass.viewContext.save()
        
    }
    
    func setupLongTapGesture(){
         
        longPressGestureRecognizer.minimumPressDuration = 0.3
        
        longPressGestureRecognizer.delegate = self
        
    }
    
}


// MARK: - Extension for TravelMapViewController
extension TravelMapViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier ==  "GoToPhotosVC" {

            let photoAlbumViewController = PhotosAlbumViewController()

            // sender is a coordinate that is placed on the map

            let coordinateFromSender = sender as! CLLocationCoordinate2D

            // pass the data controller
            photoAlbumViewController.dataControllerClass = dataControllerClass

            // pass the pin
            photoAlbumViewController.pin = pinToBePassed

            //pass the coordinates
            photoAlbumViewController.coordinateSelected = coordinateFromSender

            // pass the flick images
            photoAlbumViewController.flickerPhotos = flickrImages

        }
    }
}

