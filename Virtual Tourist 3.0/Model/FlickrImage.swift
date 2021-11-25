//
//  FlickrImage.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import Foundation

struct FlickrImage {
    
    let photoPath : String? // URL for the photos
    
    // dictionary that takes anyobject and reads the value of the key 'url_m'
    init(dictionary: [String: AnyObject]) {
        photoPath = dictionary[FlickrClient.JSONResponseKeys.MediumURL] as? String
    }
    
    
    // return an array from the results, array of type FlickrImage that contains the URL to build photos
    static func photosPathFromResults(_ results: [[String: AnyObject]]) -> [FlickrImage]{
        
        // save the photos in array of type FlickrImage
        var photosPath = [FlickrImage]()

        // loop through the dictionary (results), each result is a dictionary of 'FlickrImage'
        for result in results {
            photosPath.append(FlickrImage(dictionary: result))
        }
        
        return photosPath
        
    }
}
