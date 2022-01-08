//
//  FlickrClient.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import Foundation

class FlickrClient : NSObject {
    
    // MARK: - Properties
    
    // the shared session
    var session =  URLSession.shared
    
    // array to store URLs for image downloaded from flickr
    var photosPath : [FlickrImage] = [FlickrImage]()
    
    override init() {
        super.init()
    }
    
    // MARK: - Networking
    /*
     
     If the request is successful, I receive an array of dictionaries [FlickrImage]. Each value of the array contains URL to construct a photo
     */
    
    func getPhotosPath (lat: Double, lon: Double, _ completionHandlerForGetPhotosPath: @escaping (_ result : [FlickrImage]?, _ error : NSError?)->Void ){
        

        /*
         latitude --> latitude coordiante tapped by the user
         
         longitude --> longitude coordiante tapped by the user
         
         completionHandlerForGetPhotosPath --> handles the request, if success it stores the data else it shows an error
         */
        
        
        // parameters for the web request
        
        
        
        /*
         
         
         per_page --> number of photos to return to per page, default is 100 and max is 500
         
         page --> page of results to return, default 1
         
         
         
         Task:
            1- query the API with page = 1, get an entry for total photos available for location
         RECORD THIS NUMBER
         
            2- Next time I query the API, I should calculate the total number of pages
         
                total photos available
                    ------------
                    page size
         
         then query the API with page = randomNumber
         
         randomNumber = randomNumber between 0 and number of pages calculated eariler
         
         
         
         min(pages, 4000/per_page)
         per_page --> number of photos per page
         
         issue 2 requests
         
         1) get the pages value
         
         2) fetch the pictures --> with the random number selected
         */
        
    
        print("\(FlickrClient.ParameterKeys.Page.count)FlickrClient.ParameterKeys.Page")
        print("\(FlickrClient.ParameterValues.PerPageAmount)FlickrClient.ParameterValues.PerPageAmount")
        
        
        
        let methodParameters: [String : Any] = [
            FlickrClient.ParameterKeys.Method: FlickrClient.ParameterValues.SearchMethod,
            FlickrClient.ParameterKeys.ApiKey: FlickrClient.ParameterValues.ApiKey,
            FlickrClient.ParameterKeys.Format: FlickrClient.ParameterValues.ResponseFormat,
            FlickrClient.ParameterKeys.Lat: lat,
            FlickrClient.ParameterKeys.Lon: lon,
            FlickrClient.ParameterKeys.NoJSONCallback:FlickrClient.ParameterValues.DisableJSONCallback,
            FlickrClient.ParameterKeys.SafeSearch: FlickrClient.ParameterValues.UseSafeSearch,
            FlickrClient.ParameterKeys.Extras: FlickrClient.ParameterValues.MediumURL,
            FlickrClient.ParameterKeys.Radius: FlickrClient.ParameterValues.SearchRangeKm,
            FlickrClient.ParameterKeys.PerPage : FlickrClient.ParameterValues.PerPageAmount,
            FlickrClient.ParameterKeys.Page : Int(arc4random_uniform(6))
             

        ]
        
       
//        print("\(methodParameters) methodParameters printed ")
        
        
        
        
        
        
        // pass taskForGetMethod
        
        let _ = taskForGetMethod(methodParameters: methodParameters as [String: AnyObject]) { results, error in
            
            // send the values to the completionHandler, the values are an array of photos URL by FlickrImage
            
            if let error = error {
                
                completionHandlerForGetPhotosPath(nil, error)
                
            } else {
                
                if let photos = results?[FlickrClient.JSONResponseKeys.Photos] as? [String: AnyObject],
                
                    let photo = photos[FlickrClient.JSONResponseKeys.Photo] as? [[String:AnyObject]]{
                    
                    let flickerImage = FlickrImage.photosPathFromResults(photo)
                    
                    completionHandlerForGetPhotosPath(flickerImage, nil)
                    // fill the FlickrImage with an object of an array of dictionaries
                } else {
                    
                    completionHandlerForGetPhotosPath(nil, NSError(domain: "getPhotosPath", code: 0, userInfo: [NSLocalizedDescriptionKey:"Could not parse getPhotosPath"]))
                }
            }
        }
    }
    
    
    
    // MARK: - TaskForGet Functions
    
    
        /*
         Get request with the data
         
         methodParameters --> receives the request parameters declared above
         completionHandlerForGet -->  handles the request, if success it stores the data else it shows an error
         */
    
    func taskForGetMethod(methodParameters: [String: AnyObject], completionHandlerForGet: @escaping (_ result : AnyObject? , _ error : NSError?)->Void) -> URLSessionDataTask{
        
        // store previous parameters
        let receivedParameter = methodParameters
        
        // configure the request and build the URL
        let request = NSMutableURLRequest(url: URLsFlickerFromParameters(receivedParameter))
        
        // task to perform the request
        let task = session.dataTask(with: request as URLRequest) { data , response , error in
            
            // send error in case of request has failed
            func sendError(_ error: String){
                
                print("error received from taskForGetMethod \(error)")
                
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForGet(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            // check for errors
            guard error == nil else {
                
                sendError("An error occurred while performing the request in taskForGetMethod \(error!)")
                return
            }
            
            // check for codeStatus
            guard let codeStatus = (response as? HTTPURLResponse)?.statusCode, codeStatus >= 200 && codeStatus <= 299 else {
                
                sendError("The request returned an error other than 2XX!")
                
                return
            }
            
            // check for data
            guard let data = data else {
                
                sendError("The request did not return any data")
                
                return
            }
            
            // use the data and parse it
            self.dataConversionWithCompletionHandler(data, innerCompletionHandlerForConvertingData: completionHandlerForGet)

        }
        
        // start the task
        task.resume()
        
        // return the task
        return task
    }
    
    
    /*
     Get request for images
     
     photoPath --> url to get data for the images 
     
     completionHandlerForImage --> handle the request, if I the image data then store, else show an error
     
     */
    
    func taskForGetImage(photoPath : String, completionHandlerForImage: @escaping (_ imageData: Data?, _ error : NSError?)->Void) -> URLSessionDataTask{
        
        // set the URL
        let url = URL(string: photoPath)!
        
        // set the request with the new URL
        let request = URLRequest(url: url)
        
        // create a task
        let task = session.dataTask(with: request) { data , response , error in
            
            // send error in case of request has failed
            func sendError(_ error : String){
                print(error)
                
                let userInfo = [NSLocalizedDescriptionKey: error]
                
                completionHandlerForImage(nil, NSError(domain: "taskForGetImage", code: 1, userInfo: userInfo))
            }
            // check for errorn
            guard error == nil else {
                
                sendError("An error occurred while performing the request \(error!)")
                
                return
            }
            
            // check code status
            guard let codeStatus = (response as? HTTPURLResponse)?.statusCode, codeStatus >= 200 && codeStatus <= 299 else {
                
                sendError("The request returned an error other than 2XX!")
                
                return
            }
            
            // check for data
            guard let data = data else {
                
                sendError("There was no data returned by the request")
                
                return
            }
            // parse the data and use it
            completionHandlerForImage(data, nil)

        }
        // start the task
        task.resume()
        
        // return the task
        return task
    }
    
  
    
    
    
    // MARK: - Private Helper Functions
    /*
     Construct a URL with the necessary data
     parameters -> the parameters request
     
     */
        
    private func URLsFlickerFromParameters(_ parameters: [String:AnyObject])-> URL{
        
        var components = URLComponents()
        
        components.scheme = FlickrClient.Constants.ApiScheme
        
        components.host = FlickrClient.Constants.ApiHost
        
        components.path = FlickrClient.Constants.ApiPath
        
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            
            components.queryItems!.append(queryItem)
            
        }
        
        return components.url!
    }
    
    /*
     JSON raw data received convertied to a usable object
     
     data --> data that is received
     
     innerCompletionHandlerForConvertingData --> handle the results of the JSON deserilization if success store, else show error
     
     */
    
    private func dataConversionWithCompletionHandler(_ data: Data, innerCompletionHandlerForConvertingData: (_ result: AnyObject? , _ error : NSError?)->Void ){
        
        // results that are parsed
        var resultsParsed : AnyObject! = nil
        
        // check for error while desirializing
        do {
            
            resultsParsed = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            
        } catch {
            
            let userInfo = [NSLocalizedDescriptionKey: "The data could not be parsed as JSON \(data)"]
            
            innerCompletionHandlerForConvertingData(nil, NSError(domain: "dataConversionWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        // pass the converted data to the completionHandler 
        innerCompletionHandlerForConvertingData(resultsParsed, nil)

    }

    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton{
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    
    
}
