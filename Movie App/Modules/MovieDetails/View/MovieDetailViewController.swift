//
//  MovieDetailViewController.swift
//  Movie App
//
//  Created by Shivendra on 25/09/24.
//

import UIKit
import Kingfisher

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var movieImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releasedYearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    
    var movieData: MovieResModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetData()
    }
    
    func SetData() -> Void {
        movieImg.kf.setImage(with: URL(string: movieData?.poster ?? ""))
        titleLabel.text = "Tittle: \(movieData?.title ?? "N/A")"
        if let year = movieData?.year {
            releasedYearLabel.text = "Released Year: \(year)"
        } else {
            releasedYearLabel.text = "N/A"
        }
        if let rating = movieData?.rating {
            ratingLabel.text = "Rating: \(rating)"
        } else {
            ratingLabel.text = "N/A"
        }
        directorLabel.text = "Director: \(movieData?.director ?? "N/A")"
    }
}
