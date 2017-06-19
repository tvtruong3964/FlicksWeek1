//
//  MovieViewController.swift
//  FlicksWeek1
//
//  Created by Truong Tran on 6/18/17.
//  Copyright © 2017 Truong Tran. All rights reserved.
//

import UIKit
import AFNetworking
import RMessage

class NowPlayingMovieViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var colectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filteredArray = [Movie]()
    
    var searchActive: Bool = false
    
    
    var dataModel: DataModel!
    var movies = [Movie]()
    let urlNowPlaying = "https://api.themoviedb.org/3/movie/now_playing?api_key="
    let urlTopRated = "https://api.themoviedb.org/3/movie/top_rated?api_key="
    
    @IBOutlet weak var listOrGidSegment: UISegmentedControl!
    
    let NetworkReachabilityChanged = NSNotification.Name("NetworkReachabilityChanged")
    var previousNetworkReachabilityStatus: AFNetworkReachabilityStatus = .unknown
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        colectionView.delegate = self
        colectionView.dataSource = self
        searchBar.delegate = self
    
        searchBar.showsCancelButton = true
        
       // colectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColectionCell")
        
        colectionView.isHidden = true
        
        checkingTheNetwork()
        
        
        NotificationCenter.default.addObserver(forName: NetworkReachabilityChanged, object: nil, queue: nil, using: {
            (notification) in
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
        
        let refreshControlTable = UIRefreshControl()
        
        refreshControlTable.attributedTitle = NSAttributedString(string: "Loading ...")
        refreshControlTable.addTarget(self, action: #selector(loadDataWithRefreshControl(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControlTable, at: 0)
        
        let refreshControlColection = UIRefreshControl()
        
        refreshControlColection.attributedTitle = NSAttributedString(string: "Loading ...")
        refreshControlColection.addTarget(self, action: #selector(loadDataWithRefreshControl(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControlTable, at: 0)
        
        
        colectionView.insertSubview(refreshControlColection, at: 0)
        
        
        loadData(url: urlNowPlaying)
    }
    
    

//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        print("searchBarTextDidBeginEditing")
//        
//    }
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        print("searchBarTextDidEndEditing")
//        searchActive = false
//    }
//    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
       
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchActive = true
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty{
            searchActive = false
            self.tableView.reloadData()
            self.colectionView.reloadData()
            return
        }
        
        filteredArray = movies.filter({ (movie) -> Bool in
            let tmp = movie.title
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range != nil
        })
        
        searchActive = true
        self.tableView.reloadData()
        self.colectionView.reloadData()
        
        
    }

    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.isEmpty
//        {
//            self.searchActive = false
//            return
//        }
//        for movie in movies
//        {
//            let titleMovie = movie.title
//            let range = titleMovie.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
//            if range != nil
//            {
//                filteredArray.append(movie)
//            }
//        }
//        if filteredArray.count == 0
//        {
//            searchActive = false
//        }
//        else if filteredArray.count > 0
//        {
//            searchActive = true
//        }
//        
//        tableView.reloadData()
//    }

    @IBAction func changeListOrGidLayout(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            colectionView.isHidden = true
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
            colectionView.isHidden = false
        }
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
        dataModel.fetchMovieWithRrefeshControll(refreshControl, url: urlNowPlaying) {
            (moviesResult) -> Void in
            switch moviesResult {
                
            case let .success(movieArray):
                self.movies = movieArray
                self.tableView.reloadData()
                self.colectionView.reloadData()
            case let .failure(error):
                print("Error fetching movies: \(error)")
            }
        }
    }
    
    func loadData(url: String) {
        
        dataModel.fetchMovie(to: self.view, url: url) {
            (moviesResult) -> Void in
            switch moviesResult {
                
            case let .success(movieArray):
                self.movies = movieArray
                self.tableView.reloadData()
                self.colectionView.reloadData()
            case let .failure(error):
                print("Error fetching movies: \(error)")
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredArray.count
        } else {
            return movies.count
        }
    }
    
    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! MovieViewCell
        
        if searchActive {
            cell.title.text = filteredArray[indexPath.row].title
            cell.overview.text = filteredArray[indexPath.row].overview
            cell.poster.setImageWith(URL(string: filteredArray[indexPath.row].linkPoser)!)
        } else {
            cell.title.text = movies[indexPath.row].title
            cell.overview.text = movies[indexPath.row].overview
            cell.poster.setImageWith(URL(string: movies[indexPath.row].linkPoser)!)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! MovieDetailViewController
        
        if segue.identifier == "segueNowPlayingTable"  {
            if searchActive {
                let index = tableView.indexPathForSelectedRow!.row
                viewController.txtUrl = filteredArray[index].linkPoser
                viewController.txtTitle =  filteredArray[index].title
                viewController.txtOverview = filteredArray[index].overview
            } else {
                let index = tableView.indexPathForSelectedRow!.row
                viewController.txtUrl = movies[index].linkPoser
                viewController.txtTitle =  movies[index].title
                viewController.txtOverview = movies[index].overview
            }
            
        } else if segue.identifier == "segueNowPlayingCollection" {
            if searchActive {
                let cell = sender as! UICollectionViewCell
                let indexPathColection = colectionView!.indexPath(for: cell)
                let index = indexPathColection!.row
                viewController.txtUrl = filteredArray[index].linkPoser
                viewController.txtTitle =  filteredArray[index].title
                viewController.txtOverview = filteredArray[index].overview
            } else {
                let cell = sender as! UICollectionViewCell
                let indexPathColection = colectionView!.indexPath(for: cell)
                let index = indexPathColection!.row
                viewController.txtUrl = movies[index].linkPoser
                viewController.txtTitle =  movies[index].title
                viewController.txtOverview = movies[index].overview
            }
            
        }
    }
}

extension NowPlayingMovieViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filteredArray.count
        } else {
            return movies.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colectionView.dequeueReusableCell(withReuseIdentifier: "MovieColectionCell", for: indexPath)
            as! MovieCollectionViewCell
        
        if searchActive {
            cell.posterColectionView.setImageWith(URL(string: filteredArray[indexPath.row].linkPoser)!)
        } else {
            cell.posterColectionView.setImageWith(URL(string: movies[indexPath.row].linkPoser)!)
        }
        
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionCellSize = UIScreen.main.bounds.size.width
        let widthCell = collectionCellSize / 2.0
        
        return CGSize(width: widthCell , height: widthCell)
        
    }
    
   
    
}

