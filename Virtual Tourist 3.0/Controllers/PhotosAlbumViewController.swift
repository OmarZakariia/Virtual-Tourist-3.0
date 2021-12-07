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
    
    // core data
    var dataControllerClass : DataControllerClass!

    // map view, radius displayed from the pin
    let regionRadius : CLLocationDistance = 1000

    // collection view cell
    let photoCell = PhotoCellCollectionViewCell()

    // array of photos downloaded from flickr
    var flickerPhotos : [FlickrImage] = [FlickrImage]()

    // photos that are associated with the persisted array in core data
    var coreDataPhotos : [Photo] = []

    // pin passed from travelVC
    var pinPassedFromTravelVC : Pin! = nil

    //coordinate passed from travel VC
    var coordinatePassedFromTravelVC : CLLocationCoordinate2D!


    
    
    // photos to be deleted, change title of the button accordingly
    var selectedPhotosToDelete: [Int] = [] {
        
        didSet {
            if selectedPhotosToDelete.count > 0 {
                
                newCollectionButtonPressed.setTitle("Remove the selected pictures", for: .normal)
                
            } else {
                
                newCollectionButtonPressed.setTitle("New Collection", for: .normal)
            }
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var newCollectionButtonPressed: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mapPiece: MKMapView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        performUIUpdatesOnTheMainThread {
            
            self.collectionView.reloadData()
            
            // test
            print("\(self.coreDataPhotos.count) 📷")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("PhotosAlbumViewController loaded")
        
        newCollectionButtonPressed.isHidden = false
     
        // add the pin to the mapPiece
        addAnnotationToTheMapPiece()
        
        // setup the collection view layout
        collectionViewSetupLayout()
        
        // fetch photos
        fetchRequestForPhotos()
        
    }

    // MARK: - Core data fetch request for photos
    
    
    func fetchRequestForPhotos() {
    
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        // filter the photos that are associated with the current pin
        let predicate = NSPredicate(format: "pin == %@", pinPassedFromTravelVC)
        
        // assign the fetch request with the predicate
        fetchRequest.predicate = predicate
        
        // search result
        if let result = try? dataControllerClass.viewContext.fetch(fetchRequest){
            
            // if request is successfull, save it to the photos array
            coreDataPhotos = result
            
            // perform UI updates on the main queuue
            
            performUIUpdatesOnTheMainThread {
                
                // check to see if there are core data photos
                if self.coreDataPhotos.count == 0 {
                    // fetch photos from pin
                    self.getPhotosRequestFromPin()
                }
                
                // reload collection view with new data
                self.collectionView.reloadData()
            }
        }
        
        
    }
    
    func getPhotosRequestFromPin(){
        
        // get a new set of photos from the given pin and save them, when I get the new set I need to delete to old set
        
        FlickrClient.sharedInstance().getPhotosPath(lat: coordinatePassedFromTravelVC.latitude, lon: coordinatePassedFromTravelVC.longitude) { photos, error in
            
            // if the request was successfull
            if let photos = photos {
                
                // remove the old set of photos FIRST then update it with the new set
                self.flickerPhotos.removeAll()
                print("\(self.flickerPhotos.count) after deletion 🗑")
                
                // assign the flickerImages to the new set of photos,
                self.flickerPhotos = photos
                print("\(self.flickerPhotos.count) after update 🆕")
                
                // loop through the urls of the photos (photosPath)
                for photo in self.flickerPhotos {
                    
                    
                  // TODO:- Comment the .removeAll functions because I think its implemented in deleteSelectedPhotos, but not sure about because I am only removing the selected photos when I am NOT requesting a new collection
                    
                    // store the new photoPath
                    let newPhotoPath = photo.photoPath
                    
                    // delete the old set of photos from core data as well
                    self.coreDataPhotos.removeAll()
                    print("\(self.coreDataPhotos.count) core data photos after deletion 🗑")
                    
                    // create an instance of 'Photo' for each item of the array of received photos [FlickrImage]
                    let photoForCoreData = Photo(imageURL: newPhotoPath, context: self.dataControllerClass.viewContext)
                    
                    // assign the pin to photoForCoreData
                    photoForCoreData.pin = self.pinPassedFromTravelVC
                    
                    // append the new photos
                    self.coreDataPhotos.append(photoForCoreData)
                    print("\(self.coreDataPhotos.count) core data photos after updating 🆕")
                    
                    // save the changes
                    try? self.dataControllerClass.viewContext.save()
                    
                    // reload the collection view with the new photos
                }
                performUIUpdatesOnTheMainThread {
                    self.collectionView.reloadData()
                }
            }
            // error occured
            else {
                print(error ?? "empty message from getPhotosRequestFromPin in PhotosAlbumViewController ")
                
            }
        }
        
    }
    
    
// MARK: - Functions
    
    // return an array of the selected items
    func selectedToDeleteFromIndexPath(_ indexPathArray: [IndexPath]) -> [Int]{
        
        // array to store the selected items
        var itemsSelected : [Int] = []
        
        // iterate the indexPath
        for indexPath in indexPathArray {
            
            itemsSelected.append(indexPath.item)
        
        }
        
        return itemsSelected
        
        
    }
    
    
    func addAnnotationToTheMapPiece() {
        let annotation  = MKPointAnnotation()
        annotation.coordinate = coordinatePassedFromTravelVC
        mapPiece.addAnnotation(annotation)
        mapPiece.showAnnotations([annotation], animated: true)
        
    }
    
    // display the chosen pin from TravelMapVC in the map piece
    func displayPinChosen(location : CLLocation){
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapPiece.setRegion(coordinateRegion, animated: true)
        
    }

   
    
    // MARK: - IBAction Functions
    
    @IBAction func deleteSelectedPhotos(_ sender: UIButton) {
        
        // check if there are any selected items
        if let selectedItemsToDelete : [IndexPath] = collectionView.indexPathsForSelectedItems{
            
            // order the array
            let items = selectedItemsToDelete.map{$0.item}.sorted().reversed()
            
            // loop through the items in the array
            for item in items {
                
                // and delete the items from core data
                dataControllerClass.viewContext.delete(coreDataPhotos.remove(at: item))
            }
        }
    }
    
    
    
    @IBAction func newCollectionButtonPressed(_ sender: UIButton) {
        // if there are no selected photos then make a new request
        // DELETE THE OLD COLLECTION NOT
        // ACTIVITY INDICATOR SHOULD APPEAR while images are being downloaded
        
        if selectedPhotosToDelete.count == 0 {
            // fetch request
            fetchRequestForPhotos()
        } else {
            print("no photos selected to delete")
        }
        
    }
    
}





// MARK: - Extension for UICollectionViewLayout
extension PhotosAlbumViewController {
    
    // custom view to the uicollectionview
    func collectionViewSetupLayout() {
        
        let width = (view.frame.size.width - 20) / 3
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: width, height: width)
        
        collectionView.isHidden = false
        collectionView.allowsMultipleSelection = true
    }
}
