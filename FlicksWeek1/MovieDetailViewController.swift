//
//  MovieDetailViewController.swift
//  FlicksWeek1
//
//  Created by Truong Tran on 6/16/17.
//  Copyright © 2017 Truong Tran. All rights reserved.
//

import UIKit
import AFNetworking
import RMessage

class MovieDetailViewController: UIViewController {
    
    var txtUrl: String!
    var txtLowUrl: String!
    var txtTitle: String!
    var txtOverview: String!
    var floatVote: Float!
    var txtDate: String!
    
    
    
    @IBOutlet weak var posterDetail: UIImageView!
    @IBOutlet weak var titleDetail: UILabel!
    @IBOutlet weak var overviewDetail: UILabel!
    @IBOutlet weak var voteDetail: UILabel!
    @IBOutlet weak var dateDetail: UILabel!
    
    @IBOutlet weak var imgVote: UIImageView!
    
    @IBOutlet weak var imgDate: UIImageView!
    
    @IBOutlet weak var scrollDetail: UIScrollView!
    
    let NetworkReachabilityChanged = NSNotification.Name("NetworkReachabilityChanged")
    var previousNetworkReachabilityStatus: AFNetworkReachabilityStatus = .unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
                let smallImageRequest = NSURLRequest(url: URL(string: txtLowUrl)!)
        
                let largeImageRequest = NSURLRequest(url: URL(string: txtUrl)!)
        
        
       // posterDetail.setImageWith(URL(string: "https://image.tmdb.org/t/p/w342\(txtUrl)")!)
        
        
        
        
                self.posterDetail.setImageWith(
                    smallImageRequest as URLRequest,
                    placeholderImage: nil,
                    success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
        
                        // smallImageResponse will be nil if the smallImage is already available
                        // in cache (might want to do something smarter in that case).
                        self.posterDetail.alpha = 0.0
                        self.posterDetail.image = smallImage;
        
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
        
                            self.posterDetail.alpha = 1.0
        
                        }, completion: { (sucess) -> Void in
        
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            self.posterDetail.setImageWith(
                                largeImageRequest as URLRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
        
                                    self.posterDetail.image = largeImage;
        
                            },
                                failure: { (request, response, error) -> Void in
                                    // do something for the failure condition of the large image request
                                    // possibly setting the ImageView's image to a default image
                            })
                        })
                },
                    failure: { (request, response, error) -> Void in
                        // do something for the failure condition
                        // possibly try to get the large image
                })
        
        
        
        
        
        titleDetail.text = txtTitle
        overviewDetail.text = txtOverview
        voteDetail.text = "\(floatVote!)"
        dateDetail.text = txtDate
        
        
        overviewDetail.frame.size = CGSize(width: view.bounds.size.width - 20, height: 10000)
        titleDetail.sizeToFit()
        overviewDetail.sizeToFit()
        
        scrollDetail.contentSize = CGSize(width: scrollDetail.bounds.width,
                                          height: titleDetail.frame.size.height + overviewDetail.frame.size.height + 10)
        
        imgVote.frame = CGRect(x: titleDetail.frame.origin.x, y: titleDetail.frame.size.height + 20, width: imgVote.bounds.width, height: imgVote.frame.size.height)
        
        voteDetail.frame = CGRect(x: imgVote.frame.origin.x + 30, y: titleDetail.frame.size.height + 20, width: voteDetail.bounds.width, height: voteDetail.frame.size.height)
        
        imgDate.frame = CGRect(x: imgVote.frame.origin.x + 130, y: titleDetail.frame.size.height + 20, width: imgDate.bounds.width, height: imgDate.frame.size.height)
        
        dateDetail.frame = CGRect(x: imgDate.frame.origin.x + 30, y: titleDetail.frame.size.height + 20, width: dateDetail.bounds.width, height: dateDetail.frame.size.height)
        
        
        overviewDetail.frame = CGRect(x: titleDetail.frame.origin.x, y: titleDetail.frame.size.height + 55, width: overviewDetail.bounds.width, height: overviewDetail.frame.size.height)
        
        
        // show message error network
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if RMessage.isNotificationActive() {
            RMessage.dismissActiveNotification()
        }
    }
    
}
