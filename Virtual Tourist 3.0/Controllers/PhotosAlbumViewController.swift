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
        
        // add a pin to the map piece
        addAnnotationToTheMapPiece()
        
        // call collection view setup function
        collectionViewSetupLayout()
        
        // look for persisted photos object
        fetchRequestForPhotos()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
