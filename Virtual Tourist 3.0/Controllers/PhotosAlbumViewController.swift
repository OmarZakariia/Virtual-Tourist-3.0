//
//  PhotosAlbumViewController.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import UIKit
import MapKit
import CoreData

class PhotosAlbumViewController: UIViewController {
    
    // MARK: -  Properties
    
    // data controller for core data
    var dataControllerClass : DataControllerClass!
    
    // radius for pin
    let regionRadius : CLLocationDistance = 1000
    
    // collectionView cell
    let photoCell = PhotoCellCollectionViewCell()
    
    // array of downloaded non persisted photos from flickr
    var flickerPhotos : [FlickrImage] = [FlickrImage]()
    
    // array of persisted photos with oun
    var coreDataPhotos : [Photo] = []
    
    // pin passed from TravelMapViewController
    var pinPassedFromTravelMapViewController : Pin! = nil
    
    // coordiante for the pin passed from TravelMapViewController
    var coordianteForPinPassedFromTravelMapViewController : CLLocationCoordinate2D!
    
    var selectedPhotosToDelete: [Int] = [] {
        // if there any selected photos to then set the title button to 'Remove pictures selected' else 'New Collection'
        
        didSet {
            // there are no photos selected to delete
            if selectedPhotosToDelete.count == 0 {
                
                // Title --> 'New Collection'
                newCollectionButton.setTitle("New Collection", for: .normal)
            }
            // there are photos selected to delete
            else {
                
                // Title --> 'Remove Selected Pictures'
                newCollectionButton.setTitle("Remove Selected Pictures", for: .normal)
            }
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapPiece: MKMapView!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: - Application Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("PhotosAlbumViewController loaded")
        
        
        // hide new collection button
        //        newCollectionButton.isHidden = false
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // add a pin to the map piece
        addAnnotationToTheMapPiece()
        
        // call collection view setup function
        collectionViewSetupLayout()
        
        // look for persisted photos object
        fetchRequestForPhotos()
        
        performUIUpdatesOnTheMainThread {
            
            
            self.collectionView.reloadData()
            
            print("\(self.coreDataPhotos.count) core data photos in PhotosAlbumVC 🌁")
        }
    }
    
    // MARK: - Functions
    func addAnnotationToTheMapPiece() {
        
        let annotationToBeAdded = MKPointAnnotation()
        
        annotationToBeAdded.coordinate = coordianteForPinPassedFromTravelMapViewController
        
        
        
        mapPiece.addAnnotation(annotationToBeAdded)
        
        mapPiece.showAnnotations([annotationToBeAdded], animated: true)
    }
    
    
    // add pin on the mapPiece
    func addPinToTheMapPiece(location : CLLocation){
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapPiece.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - IBActions + Related functions
    @IBAction func deleteSelectedButtonPressed(_ sender: Any){
        
        // are there any selected items ?
        if let selectedItems : [IndexPath] =  collectionView.indexPathsForSelectedItems {
            
            // sort the items
            let items = selectedItems.map{$0.item}.sorted().reversed()
            
            // loop through items in the array
            for item in items {
                
                // delete items
                dataControllerClass.viewContext.delete(coreDataPhotos.remove(at: item))
                
                // save the context
                try? dataControllerClass.viewContext.save()
            }
            
            // remove items from the collection view
            /// TODO:- Should I remove it on the main thread?
            collectionView.deleteItems(at: selectedItems)
            
                
        }
    }
    
    // return an array with the addresses of the selected items
    func selectedPhotosToDeleteFromIndexPath(_ indexPathArray: [IndexPath]) ->[Int] {
        
        // array to store the selected items
        var selected : [Int] = []
        
        // loop through the indexPath in the indexPathArray and append the new indexPath
        for indexPath in indexPathArray {
            
            // append the new indexPath in the indexPathArray
            selected.append(indexPath.item)
        }
        
        return selected
    }
    
    @IBAction func newCollectionPhotosButtonPressed(_ sender: UIButton) {
        // are there any selected items ?
        if selectedPhotosToDelete.count == 0 {
        
            // request new collection photos
            /// TODO:-  should I remove the photos from the coredata and/or flickrPhotos array here ?// MARK: -
            
//            coreDataPhotos.removeAll()
            // remove core data photos
            for photo in coreDataPhotos {
                dataControllerClass.viewContext.delete(photo)
                try? dataControllerClass.viewContext.save()
            }
            requestFlickrPhotosFromPinPhotosVC()
        }
        // else
        else {
             // there are photos selected, do nothing
            print("there are selected photos, cant request a new set of collection")
        }
        
    }



// MARK: - CoreData Functions

// look for persisted photos and if there are any add them to the coreDataPhotos
    func fetchRequestForPhotos(){
        
        // are there any persisted 'Photo's
        let fetchRequest : NSFetchRequest <Photo> = Photo.fetchRequest()
        
        // predicate to filter photos with the current pin
        // i think 'pin' should be changed
        let newPredicate = NSPredicate(format: "pin ==%@", pinPassedFromTravelMapViewController)
        
        // assignt the new predicate to the fetchRequest
        fetchRequest.predicate = newPredicate
        
        // the results
        if let result = try? dataControllerClass.viewContext.fetch(fetchRequest) {
            
            // if the request is successful, save the photos in coreDataPhotos
             coreDataPhotos = result
            
            // should I save the context?
            
            performUIUpdatesOnTheMainThread {
            
                // check the result of the request, is the array of coreDataPhotos empty?
                if self.coreDataPhotos.count == 0 {
                    
                    // get a new set of photos
                    self.requestFlickrPhotosFromPinPhotosVC()
                }
                
                // if there are new persisted photos, update the collection view with it
                self.collectionView.reloadData()
            }
            
        }
    }
    func requestFlickrPhotosFromPinPhotosVC(){
        
        // fetch a new collection of photos associated with a pin and save them
        FlickrClient.sharedInstance().getPhotosPath(lat: coordianteForPinPassedFromTravelMapViewController.latitude, lon: coordianteForPinPassedFromTravelMapViewController.longitude) { photos, error in
            
            // check for photos
            if let photos = photos {
                
                // update the flickrPhotos array with the new collection of photos fetched
                /// TODO: - should I delete the old photos ?
                self.flickerPhotos = photos
                
                // loop through the photos urls
                for photo in self.flickerPhotos {
                    
                    // create a new constant to store the new photo urls
                    let photoPath = photo.photoPath
                    
                    // create a new instance of each 'photo' item in the array of the new received photos collection
                    let newPhotoCoreData = Photo(imageURL: photoPath, context: self.dataControllerClass.viewContext)
                    
                    // reference
                    newPhotoCoreData.pin = self.pinPassedFromTravelMapViewController
                    
                    /// TODO;- Should I empyt the coreDataPhotos array before updating it ?
                    self.coreDataPhotos.append(newPhotoCoreData)
                    
                    // save the context
                    try? self.dataControllerClass.viewContext.save()
                    
                }
                // dispatch
                performUIUpdatesOnTheMainThread {
                    
                    // reload the collection view with the new photos fetched
                    self.collectionView.reloadData()
                }
            }
            // else an error occurred
            else {
                print(error ?? "empty error from  requestFlickrPhotosFromPinPhotosVC")
            }
        }
        
    }
}

// MARK: - PhotosAlbumViewController Collection View Setup Function
extension PhotosAlbumViewController {
    
    // setup the collection view
    func collectionViewSetupLayout(){
        
        let width = (view.frame.size.width - 20) / 3
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: width, height: width)
        
        collectionView.isHidden = false
        collectionView.allowsMultipleSelection = true
    }
}
