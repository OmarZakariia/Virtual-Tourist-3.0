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
    var dataControllerClass : DataControllerClass!

    let regionRadius : CLLocationDistance = 1000

    let photoCell = PhotoCellCollectionViewCell()

    var flickerPhotos : [FlickrImage] = [FlickrImage]()

    var coreDataPhotos : [Photo] = []

    var pin : Pin! = nil

    var coordinateSelected : CLLocationCoordinate2D!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("PhotosAlbumViewController loaded")
        print("PhotosAlbumViewController loaded")
        print("PhotosAlbumViewController loaded")
    }




}




