//
//  Movie.swift
//  FlicksWeek1
//
//  Created by Truong Tran on 6/16/17.
//  Copyright © 2017 Truong Tran. All rights reserved.
//

import Foundation
class Movie {
    var title: String
    var linkPoser: String
    var vote: Float
    var overview: String
    var date: String
    init(title: String, linkPoser: String, vote: Float, overview: String, date: String) {
        self.title = title
        self.linkPoser = linkPoser
        self.vote = vote
        self.overview = overview
        self.date = date
    }
    
}
