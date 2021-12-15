//
//  PhotosAlbumViewController+UIColellectionViewMethods.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 13/12/2021.
//

import Foundation
import MapKit


// MARK: - UICollectionViewDataSource
extension PhotosAlbumViewController: UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return coreDataPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // put the persisted photos [Photo] in each item in the collection view
        let photo = coreDataPhotos[(indexPath as NSIndexPath).row]
        
        // collection view cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellCollectionViewCell", for: indexPath) as! PhotoCellCollectionViewCell
        
        /*
         Check for persistent image data, if so convert to an image and display it in the collection view, if there is no image data then perform a web request 
         */
        
        // case 1: There are image data, convert to an image
        if photo.imageData != nil {
            
            // create an image with the persisted data
            let photo = UIImage(data: photo.imageData! as Data)
            
            performUIUpdatesOnTheMainThread {
                
                // populate the cell with the new image
                cell.photoImageView.image = photo
                
                // stop the activity indicator
                cell.activityIndicator.stopAnimating()
            }
        }
        //        case 2 : there is no value, perform a web request
        else {
            // check for URL to send
            if let photoPath = photo.imageURL {
                
                // make a request
                let _ = FlickrClient.sharedInstance().taskForGetImage(photoPath: photoPath) { imageData, error in
                    
                    // check for image data
                    if let image = UIImage(data: imageData!) {
                        
                        // assign the imageData
                        photo.imageData = NSData.init(data: imageData!)
                        
                        // save the context
                        try? self.dataControllerClass.viewContext.save()
                        
                        // dispatch
                        performUIUpdatesOnTheMainThread {
                            
                            // assign cell to the new image
                            cell.photoImageView.image = image
                            
                            // stop the activity indicator
                            cell.activityIndicator.stopAnimating()
                        }
                        
                    }
                    // else error occured
                    else {
                        print(error ?? "empty error ")
                    }
                }
            }
        }

        
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension PhotosAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // assignt the property selectedPhotosToDelete to the items selected in the collection view
        selectedPhotosToDelete = selectedPhotosToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
        
        // address of the selected cell
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            cell?.contentView.alpha = 0.4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        selectedPhotosToDelete = selectedPhotosToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            cell?.contentView.alpha = 1.0
        }
    }
}
