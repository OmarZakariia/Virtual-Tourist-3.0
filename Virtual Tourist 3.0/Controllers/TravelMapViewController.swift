//
//  TravelMapViewController.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController {
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Properties
    var dataControllerClass : DataControllerClass!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
