//
//  MoviesTableViewCell.swift
//  FlicksWeek1
//
//  Created by Truong Tran on 6/16/17.
//  Copyright © 2017 Truong Tran. All rights reserved.
//

import UIKit

class MoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var overview: UILabel!
    
    var url: String!
    var txtTitle: String!
    var txtOverview: String!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
