//
//  ViewController.swift
//  alarm-you-tube
//
//  Created by Antonio Bang on 9/11/18.
//  Copyright © 2018 UCLAExtension. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    //Browser key, not iOS key
    var apiKey = "AIzaSyAfsF77pcTVfn3K_HIn0-FYMtc7ZDGsC44";
    var desiredChannelsArray = ["Google", "Apple"]
    var channelIndex = 0
    var channelsDataArray = Array<Dictionary<NSObject, Any>>();

    @IBAction func signInButton(_ sender: UIButton) {
        getChannelDetails(channelID: false)
    }
    
   
    func performGetRequest(targetURL: URL, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: Error?) -> Void) {
        let request = NSMutableURLRequest(url: targetURL)
        request.httpMethod = "GET";
        
        //Add parameters
        
        let session = URLSession.shared;
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, (response as! HTTPURLResponse).statusCode, error)
            }
                
        }
        task.resume()
    }
    
    func getChannelDetails(channelID: Bool){
        var urlString: String!
        if !channelID {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }
        
        let targetURL = URL(string: urlString);
        
        performGetRequest(targetURL: targetURL!) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data to a dictionary.
                let resultsDict = try? JSONSerialization.jsonObject(with: data!) as! Dictionary<NSObject, AnyObject>
                
                print("Returned Json data from youtube: \(resultsDict)")
//                if result = resultsDic{
//                    // Get the first dictionary item from the returned items (usually there's just one item).
//                    let items: AnyObject = resultsDict["items"] as! AnyObject
//                    let firstItemDict = (items as! Array<AnyObject>)[0] as! Dictionary<NSObject, AnyObject>
//
//                    // Get the snippet dictionary that contains the desired data.
//                    let snippetDict = firstItemDict["snippet"] as! Dictionary<NSObject, AnyObject>
//
//                    // Create a new dictionary to store only the values we care about.
//                    var desiredValuesDict: Dictionary<NSObject, AnyObject> = Dictionary<NSObject, AnyObject>()
//                    desiredValuesDict["title"] = snippetDict["title"]
//                    desiredValuesDict["description"] = snippetDict["description"]
//                    desiredValuesDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
//
//                    // Save the channel's uploaded videos playlist ID.
//                    desiredValuesDict["playlistID"] = ((firstItemDict["contentDetails"] as! Dictionary<NSObject, AnyObject>)["relatedPlaylists"] as! Dictionary<NSObject, AnyObject>)["uploads"]
//
//
//                    // Append the desiredValuesDict dictionary to the following array.
//                    self.channelsDataArray.append(desiredValuesDict)
//                }
               
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    private func apiCall() {
        //Using Youtube API
        let baseURL = " https://www.googleapis.com/youtube/v3/search";
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            if let url = URL(string: baseURL){
                let session = URLSession.shared;
                
                let request = NSMutableURLRequest(url: url);
                request.httpMethod = "GET";
                
                //Add parameters
                
                
                let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                    if error != nil {
                        print("error: \(error!)")
                        return;
                    }
                    
                    if let urlContent = data {
                        
                        DispatchQueue.main.sync {
                            
                        }
                        
                    }
                }
                
                task.resume();
            }
        }
    }
    
    
    
    
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeYouTubeReadonly]
    
    private let service = GTLRYouTubeService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        
        // Add a UITextView to display output.
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        view.addSubview(output);
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchChannelResource()
        }
    }
    
    
    // List up to 10 files in Drive
    func fetchChannelResource() {
        let query = GTLRYouTubeQuery_ChannelsList.query(withPart: "snippet,statistics")
        query.identifier = "UC_x5XG1OV2P6uZZ5FSM9Ttw"
        // To retrieve data for the current user's channel, comment out the previous
        // line (query.identifier ...) and uncomment the next line (query.mine ...)
        // query.mine = true
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_ChannelListResponse,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var outputText = ""
        if let channels = response.items, !channels.isEmpty {
            let channel = response.items![0]
            let title = channel.snippet!.title
            let description = channel.snippet?.descriptionProperty
            let viewCount = channel.statistics?.viewCount
            outputText += "title: \(title!)\n"
            outputText += "description: \(description!)\n"
            outputText += "view count: \(viewCount!)\n"
        }
        output.text = outputText
    }
    
    
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}

