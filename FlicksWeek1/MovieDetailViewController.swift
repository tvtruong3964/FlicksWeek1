//
//  MovieDetailViewController.swift
//  FlicksWeek1
//
//  Created by Truong Tran on 6/16/17.
//  Copyright © 2017 Truong Tran. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailViewController: UIViewController {
    
    var txtUrl: String!
    var txtTitle: String!
    var txtOverview: String!
    
    
    @IBOutlet weak var posterDetail: UIImageView!
    @IBOutlet weak var titleDetail: UILabel!
    @IBOutlet weak var overviewDetail: UILabel!
    
    @IBOutlet weak var scrollDetail: UIScrollView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        posterDetail.setImageWith(URL(string: txtUrl)!)
        titleDetail.text = txtTitle
        overviewDetail.text = txtOverview
        
        
       // overviewDetail.frame.size = CGSize(width: view.bounds.size.width - 20, height: 10000)
        titleDetail.sizeToFit()
        overviewDetail.sizeToFit()
        
        scrollDetail.contentSize = CGSize(width: scrollDetail.bounds.width,
                                          height: titleDetail.frame.size.height + overviewDetail.frame.size.height + 10)
        
        overviewDetail.frame = CGRect(x: titleDetail.frame.origin.x, y: titleDetail.frame.size.height + 20, width: overviewDetail.bounds.width, height: overviewDetail.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
