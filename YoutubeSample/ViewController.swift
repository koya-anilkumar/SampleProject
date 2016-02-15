//
//  ViewController.swift
//  YoutubeSample
//
//  Created by AnilKumar Koya on 09/11/15.
//  Copyright © 2015 AnilKumar Koya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tableView : UITableView!
    
    
    let APIKey : NSString = "AIzaSyBiYdLWMyoUz_B6EGQ3IFhVYQLYOb6X_zE"
    var desiredChannelsArray = ["Apple", "Google", "Microsoft"]
    var channelIndex = 0
    var channelsDataArray: Array<Dictionary<NSObject, AnyObject>> = []
    var videosArray: Array<Dictionary<NSObject, AnyObject>> = []
    var selectedVideoIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.getChannelDetails(false)
    }

    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            })
        })
        
        task.resume()
    }
    
    
    func getChannelDetails(useChannelIDParam: Bool) {
        var urlString: String!
        if !useChannelIDParam {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(desiredChannelsArray[channelIndex])&key=\(APIKey)"
        }
        else {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=\(desiredChannelsArray[channelIndex])&key=\(APIKey)"
        }
        
        let targetURL = NSURL(string: urlString)
        
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data to a dictionary.
                let resultsDict = (try! NSJSONSerialization.JSONObjectWithData(data!, options: [])) as! Dictionary<NSObject, AnyObject>
                
                // Get the first dictionary item from the returned items (usually there's just one item).
                let items: AnyObject! = resultsDict["items"] as AnyObject!
                let firstItemDict = (items as! Array<AnyObject>)[0] as! Dictionary<NSObject, AnyObject>
                
                // Get the snippet dictionary that contains the desired data.
                let snippetDict = firstItemDict["snippet"] as! Dictionary<NSObject, AnyObject>
                
                // Create a new dictionary to store only the values we care about.
                var desiredValuesDict: Dictionary<NSObject, AnyObject> = Dictionary<NSObject, AnyObject>()
                desiredValuesDict["title"] = snippetDict["title"]
                desiredValuesDict["description"] = snippetDict["description"]
                desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                
                // Save the channel's uploaded videos playlist ID.
                desiredValuesDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<NSObject, AnyObject>)["relatedPlaylists"] as! Dictionary<NSObject, AnyObject>)["uploads"]
                
                
                // Append the desiredValuesDict dictionary to the following array.
                self.channelsDataArray.append(desiredValuesDict)
                
                
                // Reload the tableview.
                //self.tblVideos.reloadData()
                
                // Load the next channel data (if exist).
                ++self.channelIndex
                if self.channelIndex < self.desiredChannelsArray.count {
                    self.getChannelDetails(useChannelIDParam)
                }
                else {
                    //self.viewWait.hidden = true
                }
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
            }
        })
    }
    
    
    func getVideosForChannelAtIndex(index: Int!) {
        // Get the selected channel's playlistID value from the channelsDataArray array and use it for fetching the proper video playlst.
        let playlistID = channelsDataArray[index]["playlistID"] as! String
        
        // Form the request URL string.
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(playlistID)&key=\(APIKey)"
        
        // Create a NSURL object based on the above string.
        let targetURL = NSURL(string: urlString)
        
        // Fetch the playlist from Google.
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data into a dictionary.
                let resultsDict = (try! NSJSONSerialization.JSONObjectWithData(data!, options: [])) as! Dictionary<NSObject, AnyObject>
                
                // Get all playlist items ("items" array).
                let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
                
                // Use a loop to go through all video items.
                for var i=0; i<items.count; ++i {
                    let playlistSnippetDict = (items[i] as Dictionary<NSObject, AnyObject>)["snippet"] as! Dictionary<NSObject, AnyObject>
                    
                    // Initialize a new dictionary and store the data of interest.
                    var desiredPlaylistItemDataDict = Dictionary<NSObject, AnyObject>()
                    
                    desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
                    desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                    desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<NSObject, AnyObject>)["videoId"]
                    
                    // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                    self.videosArray.append(desiredPlaylistItemDataDict)
                    
                    // Reload the tableview.
                    //self.tblVideos.reloadData()
                }
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel videos: \(error)")
            }
            
            // Hide the activity indicator.
            //self.viewWait.hidden = true
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    


}

