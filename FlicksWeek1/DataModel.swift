//
//  FlickAPI.swift
//  FlicksWeek1
//
//  Created by Truong Tran on 6/16/17.
//  Copyright © 2017 Truong Tran. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

enum MovieResult {
    case success([Movie])
    case failure(Error)
}

class DataModel {
    
    
    func fetchMovie(to view: UIView, url: String, completion: @escaping (MovieResult) -> Void) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "\(url)\(apiKey)")
        
        let request = URLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
        
        
       
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let hub = MBProgressHUD.showAdded(to: view, animated: true)
        hub.label.text = "Loading ..."
        
        let task: URLSessionDataTask = session.dataTask(with: request) {
            (data, reponse, error) in
            
            MBProgressHUD.hide(for: view, animated: true)
            
            self.processMovieRequest(data: data, error: error) {
                (result) in
                    completion(result)
            }
            
            
        }
        task.resume()
    }
    
    
    func fetchMovieWithRrefeshControll(_ refreshControl: UIRefreshControl, url: String, completion: @escaping (MovieResult) -> Void) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "\(url)\(apiKey)")
        let request = URLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
        
        
        
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request) {
            (data, reponse, error) in
            
            refreshControl.endRefreshing()
            
            self.processMovieRequest(data: data, error: error) {
                (result) in
                completion(result)
            }
            
            
        }
        task.resume()
    }
    
    private func processMovieRequest (data: Data?, error: Error?, completion: @escaping (MovieResult) -> Void) {
        guard let jsonData = data else {
            completion(.failure(error!))
            return
        }
        var movies = [Movie]()
        if let reponseDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary{
            let jsonArray = reponseDictionary["results"] as! [NSDictionary]
            for jsonObject in jsonArray {
                let title = jsonObject["title"] as? String
                let linkPoster = jsonObject["poster_path"] as? String
                let vote = jsonObject["vote_average"] as? Float
                let overview = jsonObject["overview"] as? String
                let date = jsonObject["release_date"] as? String
                
                let movie = Movie(title: title!, linkPoser: linkPoster!, vote: vote!, overview: overview!, date: date!)
                movies.append(movie)
            }
        }
        completion(.success(movies))
        
    }
}
