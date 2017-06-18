//
//  TopRatedTableViewController.swift
//  FlicksWeek1
//
//  Created by Truong Tran on 6/18/17.
//  Copyright © 2017 Truong Tran. All rights reserved.
//

import UIKit
import AFNetworking
import RMessage

class TopRatedTableViewController: UITableViewController {

    
    var dataModel: DataModel!
    var movies = [Movie]()
    
    let urlTopRated = "https://api.themoviedb.org/3/movie/top_rated?api_key="
    
    
    
    let NetworkReachabilityChanged = NSNotification.Name("NetworkReachabilityChanged")
    var previousNetworkReachabilityStatus: AFNetworkReachabilityStatus = .unknown
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
      //  checkingTheNetwork()
        
        
        NotificationCenter.default.addObserver(forName: NetworkReachabilityChanged, object: nil, queue: nil, using: {
            (notification) in
            print("show notification")
            
            if let userInfo = notification.userInfo {
                if let messageTitle = userInfo["summary"] as? String, let reachabilityStatus = userInfo["reachabilityStatus"] as? String, let reachableStatus = userInfo["reachableStatus"] as? Bool {
//                    if reachableStatus {
//                        RMessage.showNotification(in: self, title: messageTitle, subtitle: reachabilityStatus, type: RMessageType.success, customTypeName: nil, callback: nil)
//                        //self.loadData()
//                        
//                    } else {
//                        RMessage.showNotification(in: self, title: messageTitle, subtitle: reachabilityStatus, type: RMessageType.error, customTypeName: nil, callback: nil)
//                    }
                }
            }
        })
        
        
        // add refreshControl
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading ...")
        refreshControl.addTarget(self, action: #selector(loadDataWithRefreshControl(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        
        loadData()
    }
    
    func checkingTheNetwork() {
        AFNetworkReachabilityManager.shared().startMonitoring()
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) in
            let reachabilityStatus = AFStringFromNetworkReachabilityStatus(status)
            var networkSummary = ""
            var reachableStatusBool = false
            
            switch (status) {
            case .reachableViaWWAN, .reachableViaWiFi:
                // Reachable.
                networkSummary = "Connected to Network"
                reachableStatusBool = true
            default:
                // Not reachable.
                networkSummary = "Disconnected from Network"
                reachableStatusBool = false
            }
            
            // Any class which has observer for this notification will be able to report loss of network connection
            // successfully.
            
            if (self.previousNetworkReachabilityStatus != .unknown && status != self.previousNetworkReachabilityStatus) {
                NotificationCenter.default.post(name: self.NetworkReachabilityChanged, object: nil, userInfo: [
                    "reachabilityStatus" : "Connection Status : \(reachabilityStatus)",
                    "summary" : networkSummary,
                    "reachableStatus" : reachableStatusBool
                    ])
            }
            self.previousNetworkReachabilityStatus = status
        }
    }
    
    func loadDataWithRefreshControl(_ refreshControl: UIRefreshControl) {
        dataModel.fetchMovieWithRrefeshControll(refreshControl, url: urlTopRated) {
            (moviesResult) -> Void in
            switch moviesResult {
                
            case let .success(movieArray):
                self.movies = movieArray
                self.tableView.reloadData()
            case let .failure(error):
                print("Error fetching movies: \(error)")
            }
        }
    }
    
    func loadData() {
        
        dataModel.fetchMovie(to: self.view, url: urlTopRated) {
            (moviesResult) -> Void in
            switch moviesResult {
                
            case let .success(movieArray):
                self.movies = movieArray
                self.tableView.reloadData()
            case let .failure(error):
                print("Error fetching movies: \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return movies.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MoviesTableViewCell
        
        cell.title.text = movies[indexPath.row].title
        cell.overview.text = movies[indexPath.row].overview
        cell.poster.setImageWith(URL(string: movies[indexPath.row].linkPoser)!)
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! MovieDetailViewController
        
        let index = tableView.indexPathForSelectedRow!.row
        viewController.txtUrl = movies[index].linkPoser
        viewController.txtTitle =  movies[index].title
        viewController.txtOverview = movies[index].overview
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
