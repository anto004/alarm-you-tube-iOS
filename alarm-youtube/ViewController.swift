//
//  ViewController.swift
//  alarm-youtube
//
//  Created by Antonio Bang on 9/14/18.
//  Copyright © 2018 UCLAExtension. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var alarmTableView: UITableView!
    
   
//    //Browser key, not iOS key
    var apiKey = "AIzaSyAfsF77pcTVfn3K_HIn0-FYMtc7ZDGsC44";
    var desiredChannelsArray = ["Google", "Apple"]
    var channelIndex = 0
    var channelsDataArray = Array<Dictionary<NSObject, Any>>();


    @IBAction func fetchButton(_ sender: UIButton) {
        getChannelDetails(channelID: false);
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
                let resultsDict = try? JSONSerialization.jsonObject(with: data!) as! Dictionary<String, Any>

                if let results = resultsDict {
                    var values = [String: Any]();
                    let itemsArray = results["items"] as! [Any];
                    let item = itemsArray[0] as! [String: Any];

                    //Get Snippets
                    let snippet = item["snippet"] as! [String: Any];
                    values["title"] = snippet["title"];
                    values["description"] = snippet["description"];
                    if let thumbnail = snippet["thumbnails"] as? [String: Any], let defaultObj = thumbnail["default"] as? [String: Any]{
                        values["thumbnail"] = defaultObj["url"];
                    }

                    //Get Uploads playlist ID
                    let contentDetails = item["contentDetails"] as! [String: Any];
                    let relatedPlaylists = contentDetails["relatedPlaylists"] as! [String: Any];
                    values["playlistID"] = relatedPlaylists["uploads"];

                }

            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        alarmTableView.delegate = self;
        alarmTableView.dataSource = self;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell();
        cell = tableView.dequeueReusableCell(withIdentifier: "alarmListCell", for: indexPath);
        var alarmLabel = cell.viewWithTag(10) as! UILabel;
        alarmLabel.text = "Alarm"
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    


}

