//
//  DataSourceDelegate.swift
//  MovieFinder
//
//  Created by Yosif Iliev on 22.08.19.
//  Copyright © 2019 Yosif Iliev. All rights reserved.
//

import Foundation

protocol DataSourceDelegate: class {
    func movieOnFocus(title: String, voteAverage: Double?, genreIds: [Int]?, imageURL: URL?)
}
