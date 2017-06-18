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
    init(title: String, linkPoser: String, vote: Float, overview: String) {
        self.title = title
        self.linkPoser = "https://image.tmdb.org/t/p/w342\(linkPoser)"
        self.vote = vote
        self.overview = overview
    }
    
}
