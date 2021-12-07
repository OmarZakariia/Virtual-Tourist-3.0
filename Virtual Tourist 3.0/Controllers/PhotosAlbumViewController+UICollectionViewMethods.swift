//
//  PhotosAlbumViewController+UICollectionViewMethods.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 02/12/2021.
//

import Foundation
import CoreData
import MapKit

// Extension for UICollectionViewDelegate and DataSource Methods


// MARK: - DataSource Functions

extension PhotosAlbumViewController: UICollectionViewDataSource{
    
    // get the photos stored in core data
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return coreDataPhotos.count
    }
    
    // populate the cell and assign the photos accordingly
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // place the peristed photos in the collection view
        let photo = coreDataPhotos[(indexPath as NSIndexPath).row]
        
        // reusable cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellCollectionViewCell", for: indexPath) as! PhotoCellCollectionViewCell
        
        // check if there persisted images data, if yes then convert to images, if not then perform a web request
        
        // case 1: yes there are images then convert them
        if photo.imageData != nil {
            
            // create the image with the persisted data
            let photoCreated = UIImage(data: photo.imageData! as Data)
            
                // update the UI on the main queue
            performUIUpdatesOnTheMainThread{
                
                // put the images in the cell
                cell.photoImageView.image =  photoCreated
                
                // stop the activity indicator
                cell.activityIndicator.stopAnimating()
            }
        }
        // case 2: no there are no persisted images, so perform a web request and then convert them
        else {
            
            // check if there is a photoURL to send to the request
            if let photoPath = photo.imageURL {
                
                // create a web request and send the URLS to obtain the images
                let _ = FlickrClient.sharedInstance().taskForGetImage(photoPath: photoPath) { imageData, error in
                    
                    // if the imageData is available, convert it to an image
                    if let imageCreated = UIImage(data: imageData!){
                        
                        // assign the image property to the image data obtained
                        photo.imageData = NSData.init(data: imageData!)
                        
                        // save the changes made
                        try? self.dataControllerClass.viewContext.save()
                        
                        // update the UI on the main queue
                        performUIUpdatesOnTheMainThread {
                            
                            // put the images in the cell
                            cell.photoImageView.image =  imageCreated
                            
                            // stop the activity indicator
                            cell.activityIndicator.stopAnimating()
                        }
                    }
                    // error occured
                    else {
                        print(error ?? "empty error from cellForItemAt PhotosAlbumViewControllerDataSource ")
                    }
                }
            }
        }
        
        return cell
    }
}


// MARK: - Delegate Functions
extension PhotosAlbumViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
        selectedPhotosToDelete = selectedToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            cell?.contentView.alpha = 1.0
        }
    }
}
