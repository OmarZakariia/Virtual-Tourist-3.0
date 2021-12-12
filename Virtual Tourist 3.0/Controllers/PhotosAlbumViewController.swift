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
    
    // MARK: - IBOutlets


    // MARK: - Application Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("PhotosAlbumViewController loaded")
        
    }
    
    // MARK: - Functions 
    




}




