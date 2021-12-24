//
//  TravelMapViewController.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import UIKit
import MapKit
import CoreData

class TravelMapViewController: UIViewController, UIGestureRecognizerDelegate {

    /*
     Class to show the MapView and enable user to add/remove pins

     */


    // MARK: - IBOutlet/

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var deletePinsMessage: UIView!




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
        

        setupLongTapGestureRecognizer()
        
        // call the fetch request for pins
        fetchRequestForPins()
        
        print("view has loaded")
     
    }

    // MARK: - Functions

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        deletePinsMessage.isHidden = !editing
        
        print("set editing called")
        
        editMode = editing
    }

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
    
    
    
 
    

    
    
    func setupLongTapGestureRecognizer(){
        
        // create a new long tap gesture recognizer
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addPinsToMap))
        
        // add the long tap gesture to the map view
        mapView.addGestureRecognizer(longTapGestureRecognizer)
        
        // set the min duration for the long press gesture to 0.5
        longTapGestureRecognizer.minimumPressDuration = 0.5
        
        // assign the delegate
        longTapGestureRecognizer.delegate = self
    }
    
    
    @IBAction func addPinsToMap(_ sender: UILongPressGestureRecognizer) {
        print("new pin added")
        
        if sender.state != .began {
            return
        }
        
        if !editMode {
            
            let gestureTouchLocation : CGPoint = sender.location(in: mapView)
            
            let coordinateToAdd : CLLocationCoordinate2D = mapView.convert(gestureTouchLocation, toCoordinateFrom: mapView)
            
            let annotation : MKPointAnnotation = MKPointAnnotation()
            
            annotation.coordinate = coordinateToAdd
            
            mapView.addAnnotation(annotation)
            
            addPinToCoreData(coordiante: coordinateToAdd)
            
            requestFlickrPhotosFromPin(coordinate: coordinateToAdd)
        }
        
    }
    

    
    func requestFlickrPhotosFromPin(coordinate: CLLocationCoordinate2D){
        FlickrClient.sharedInstance().getPhotosPath(lat: coordinate.latitude, lon: coordinate.longitude) { photos, error in
            
            // check that the request was successful
            if let photos = photos {
                
                // store the photos in the 'photos' object
                self.flickrImages = photos
//                DispatchQueue.main.async {
//                    self.performSegue(withIdentifier: "GoToPhotosVC", sender: coordinate)
//                }
                
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
    

    
}


// MARK: - Extension for TravelMapViewController
extension TravelMapViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier ==  "GoToPhotosVC" {

//            let photoAlbumViewController = PhotosAlbumViewController()
//
//            // sender is a coordinate that is placed on the map
//
//            let coordinateFromSender = sender as! CLLocationCoordinate2D
//
//            // pass the data controller
//            photoAlbumViewController.dataControllerClass = dataControllerClass
//
//            // pass the pin selected to PhotosAlbumViewControlle
//            photoAlbumViewController.pinPassedFromTravelMapViewController = pinToBePassed
//            print("\(pinToBePassed) pinToBePassed 📌")
//
//            //pass the coordinates of the pin selected to PhotosAlbumViewController
//            photoAlbumViewController.coordianteForPinPassedFromTravelMapViewController = coordinateFromSender
//            print("\(coordinateFromSender)coordinateFromSender 🧭")
//
//            // pass the flick images
//            photoAlbumViewController.flickerPhotos = flickrImages
            
            let photoAlbumVC = segue.destination as! PhotosAlbumViewController
            
            let coord = sender as! CLLocationCoordinate2D
            
            photoAlbumVC.dataControllerClass = dataControllerClass
            
            photoAlbumVC.pinPassedFromTravelMapViewController = pinToBePassed
            
            photoAlbumVC.coordianteForPinPassedFromTravelMapViewController = coord
            
            photoAlbumVC.flickerPhotos = flickrImages
            

        }
    }
}

