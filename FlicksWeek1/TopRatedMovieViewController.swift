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

class TopRatedMovieViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var colectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filteredArray = [Movie]()
    var searchActive: Bool = false
    
    var dataModel: DataModel!
    var movies = [Movie]()
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
        
       //  searchBar.showsCancelButton = true
        
      //  searchBar.backgroundColor = UIColor.white
        
        tableView.backgroundColor = UIColor(red: 241/255, green: 178/255, blue: 68/255, alpha: 1)
        
        navigationController!.navigationBar.barTintColor = UIColor(red: 241/255, green: 178/255, blue: 68/255, alpha: 1)
        
       // colectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColectionCell")
        
        colectionView.isHidden = true
        
       // checkingTheNetwork()
        
        
        NotificationCenter.default.addObserver(forName: NetworkReachabilityChanged, object: nil, queue: nil, using: {
            (notification) in
            if self.isViewLoaded && (self.view.window != nil) {
            if let userInfo = notification.userInfo {
                
                    if let messageTitle = userInfo["summary"] as? String, let reachabilityStatus = userInfo["reachabilityStatus"] as? String, let reachableStatus = userInfo["reachableStatus"] as? Bool {
                        if RMessage.isNotificationActive() {
                            RMessage.dismissActiveNotification()
                        }
                        if reachableStatus {
                            RMessage.showNotification(in: self, title: messageTitle, subtitle: reachabilityStatus, type: RMessageType.success, customTypeName: nil, callback: nil)
                            
                        } else {
                            RMessage.showNotification(in: self, title: messageTitle, subtitle: reachabilityStatus, type: RMessageType.error, customTypeName: nil, callback: nil)
                        }
                    }
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

        
        
        loadData(url: urlTopRated)
    }
    
    
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
    
    @IBAction func changeListOrGidLayout(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            colectionView.isHidden = true
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
            colectionView.isHidden = false
        }
    }
    
    func loadDataWithRefreshControl(_ refreshControl: UIRefreshControl) {
        dataModel.fetchMovieWithRrefeshControll(refreshControl, url: urlTopRated) {
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
        cell.selectionStyle = .none
        
        
        if searchActive {
            cell.title.text = filteredArray[indexPath.row].title
            cell.overview.text = filteredArray[indexPath.row].overview
            //cell.poster.setImageWith(URL(string: filteredArray[indexPath.row].linkPoser)!)
            
            let imageRequest = NSURLRequest(url: URL(string: "https://image.tmdb.org/t/p/w342\(filteredArray[indexPath.row].linkPoser)")!)
            
            cell.poster.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.poster.alpha = 0.0
                        cell.poster.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.poster.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.poster.image = image
                    }
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
            
            
        } else {
            cell.title.text = movies[indexPath.row].title
            cell.overview.text = movies[indexPath.row].overview
            //cell.poster.setImageWith(URL(string: movies[indexPath.row].linkPoser)!)
            
            
           // let imageRequest = NSURLRequest(url: URL(string: movies[indexPath.row].linkPoser)!)
            
            let imageRequest = NSURLRequest(url: URL(string: "https://image.tmdb.org/t/p/w342\(movies[indexPath.row].linkPoser)")!)
            
            cell.poster.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.poster.alpha = 0.0
                        cell.poster.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.poster.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.poster.image = image
                    }
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }
        
        
        return cell
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if RMessage.isNotificationActive() {
            RMessage.dismissActiveNotification()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! MovieDetailViewController
        
        if segue.identifier == "segueTopRatedTable"  {
            if searchActive {
                let index = tableView.indexPathForSelectedRow!.row
                viewController.txtUrl = "https://image.tmdb.org/t/p/original\(filteredArray[index].linkPoser)"
                viewController.txtLowUrl = "https://image.tmdb.org/t/p/w45\(filteredArray[index].linkPoser)"
                viewController.txtTitle =  filteredArray[index].title
                viewController.txtOverview = filteredArray[index].overview
                viewController.txtDate = filteredArray[index].date
                viewController.floatVote = filteredArray[index].vote
            } else {
                let index = tableView.indexPathForSelectedRow!.row
                viewController.txtUrl = "https://image.tmdb.org/t/p/original\(movies[index].linkPoser)"
                viewController.txtLowUrl = "https://image.tmdb.org/t/p/w45\(movies[index].linkPoser)"
                viewController.txtTitle =  movies[index].title
                viewController.txtOverview = movies[index].overview
                viewController.txtDate = movies[index].date
                viewController.floatVote = movies[index].vote
            }
            
        } else if segue.identifier == "segueTopRatedCollection" {
            if searchActive {
                let cell = sender as! UICollectionViewCell
                let indexPathColection = colectionView!.indexPath(for: cell)
                let index = indexPathColection!.row
                viewController.txtUrl = "https://image.tmdb.org/t/p/original\(filteredArray[index].linkPoser)"
                viewController.txtLowUrl = "https://image.tmdb.org/t/p/w45\(filteredArray[index].linkPoser)"
                viewController.txtTitle =  filteredArray[index].title
                viewController.txtOverview = filteredArray[index].overview
                viewController.txtDate = filteredArray[index].date
                viewController.floatVote = filteredArray[index].vote
            } else {
                let cell = sender as! UICollectionViewCell
                let indexPathColection = colectionView!.indexPath(for: cell)
                let index = indexPathColection!.row
                viewController.txtUrl = "https://image.tmdb.org/t/p/original\(movies[index].linkPoser)"
                viewController.txtLowUrl = "https://image.tmdb.org/t/p/w45\(movies[index].linkPoser)"
                viewController.txtTitle =  movies[index].title
                viewController.txtOverview = movies[index].overview
                viewController.txtDate = movies[index].date
                viewController.floatVote = movies[index].vote
            }
            
        }
    }
}

extension TopRatedMovieViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filteredArray.count
        } else {
            return movies.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colectionView.dequeueReusableCell(withReuseIdentifier: "MovieColectionCell1", for: indexPath)
            as! MovieCollectionViewCell
        if searchActive {
          //  cell.posterColectionView.setImageWith(URL(string: filteredArray[indexPath.row].linkPoser)!)
            
           // let imageRequest = NSURLRequest(url: URL(string: filteredArray[indexPath.row].linkPoser)!)
            let imageRequest = NSURLRequest(url: URL(string: "https://image.tmdb.org/t/p/w342\(filteredArray[indexPath.row].linkPoser)")!)
            
            cell.posterColectionView.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterColectionView.alpha = 0.0
                        cell.posterColectionView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterColectionView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterColectionView.image = image
                    }
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
            
            
        } else {
            //cell.posterColectionView.setImageWith(URL(string: movies[indexPath.row].linkPoser)!)
            
            
           // let imageRequest = NSURLRequest(url: URL(string: movies[indexPath.row].linkPoser)!)
            
            let imageRequest = NSURLRequest(url: URL(string: "https://image.tmdb.org/t/p/w342\(movies[indexPath.row].linkPoser)")!)
            
            cell.posterColectionView.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterColectionView.alpha = 0.0
                        cell.posterColectionView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterColectionView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterColectionView.image = image
                    }
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
            
        }
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionCellSize = UIScreen.main.bounds.size.width
        let widthCell = collectionCellSize / 2.0
        
        return CGSize(width: widthCell , height: widthCell)
        
    }
    
   
    
}

