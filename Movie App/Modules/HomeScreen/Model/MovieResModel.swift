//
//  MovieResModel.swift
//  Movie App
//
//  Created by Shivendra on 25/09/24.
//

import Foundation

struct MovieResModel: Codable {
    let id: Int?
    let title: String?
    let poster: String?
    let rating: Double?
    let year: Int?
    let director: String?
}
