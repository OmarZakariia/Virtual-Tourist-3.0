//
//  TravelMapViewController.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController {
    
    /*
     Class to show the MapView and enable user to add/remove pins
     
     */
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deletePinsMessage: UIView!
    
    
    
    // MARK: - Properties
    
    // CoreData
    var dataControllerClass : DataControllerClass!
    
    var editMode : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - UILongTapGestureRecognizer
    


}
