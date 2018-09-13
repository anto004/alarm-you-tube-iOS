//
//  ViewController.swift
//  alarm-you-tube
//
//  Created by Antonio Bang on 9/11/18.
//  Copyright © 2018 UCLAExtension. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func signInButton(_ sender: UIButton) {
        
    }
    
    private func apiCall() {
        //Using Yelp API to find restaurants nearby
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

}

