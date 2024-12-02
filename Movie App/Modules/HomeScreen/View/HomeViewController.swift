//
//  HomeViewController.swift
//  Movie App
//
//  Created by Shivendra on 25/09/24.
//

import UIKit
import Kingfisher
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    
    private var loader: Loader?
    let movieListVM = MovieListVM()
    var movieData = [MovieResModel]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCollectionViewLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader = Loader(in: self.view)
        FetchMovieData()
        registerCellNib()
        setupCollectionView()
        setupRefreshControl()
    }
    
    func setupCollectionViewLayout() {
        if let layout = movieCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let padding: CGFloat = 16
            let itemSpacing: CGFloat = 8
            let totalPadding = padding * 2 + itemSpacing
            let itemWidth = (view.bounds.width - totalPadding) / 2
            layout.itemSize = CGSize(width: itemWidth, height: 220)
            layout.minimumInteritemSpacing = itemSpacing
            layout.minimumLineSpacing = 16
        }
    }
    
    func setupCollectionView() -> Void {
        movieCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            movieCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            movieCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            movieCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            movieCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }

    func registerCellNib() -> Void {
        let cellNib = UINib(nibName: "MovieCollectionViewCell", bundle: nil)
        movieCollectionView.register(cellNib, forCellWithReuseIdentifier: "MovieCollectionViewCell")
    }
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshMovies), for: .valueChanged)
        movieCollectionView.refreshControl = refreshControl
    }
    
    @objc func refreshMovies() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.refreshControl.endRefreshing()
            self.FetchMovieData()
        }
    }
    
    func FetchMovieData() {
        let savedMovies = fetchMoviesFromCoreData(offset: 0, limit: 8)
        
        if !savedMovies.isEmpty {
            movieData = savedMovies
            DispatchQueue.main.async {
                self.movieCollectionView.reloadData()
                self.loader?.hide()
            }
        } else {
            if NetworkMonitor.shared.isConnected {
                movieListVM.fetchMovies { result in
                    switch result {
                    case .success(let movies):
                        self.deleteAllMoviesFromCoreData()
                        self.saveMoviesToCoreData(movies)
                        self.movieData = movies
                        DispatchQueue.main.async {
                            self.movieCollectionView.reloadData()
                            self.loader?.hide()
                        }
                    case .failure(let error):
                        print("Failed to fetch movies: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func deleteAllMoviesFromCoreData() {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<MoveEntity> = MoveEntity.fetchRequest()
        
        do {
            let movieEntities = try context.fetch(fetchRequest)
            for entity in movieEntities {
                context.delete(entity)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to delete movies: \(error)")
        }
    }

    func saveMoviesToCoreData(_ movies: [MovieResModel]) {
        let context = CoreDataManager.shared.context
        
        for movie in movies {
            let movieEntity = MoveEntity(context: context)
            movieEntity.id = Int64(movie.id ?? 0)
            movieEntity.title = movie.title
            movieEntity.poster = movie.poster
            movieEntity.rating = movie.rating ?? 0.0
            movieEntity.year = Int64(movie.year ?? 0)
            movieEntity.director = movie.director
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    func fetchMoviesFromCoreData(offset: Int, limit: Int) -> [MovieResModel] {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<MoveEntity> = MoveEntity.fetchRequest()
        
        if offset > 0 {
            fetchRequest.fetchOffset = offset
        }
        if limit > 0 {
            fetchRequest.fetchLimit = limit
        }
        
        do {
            let movieEntities = try context.fetch(fetchRequest)
            loader?.hide()
            return movieEntities.map { MovieResModel(id: Int($0.id), title: $0.title, poster: $0.poster, rating: $0.rating, year: Int($0.year), director: $0.director) }
        } catch {
            print("Failed to fetch movies from Core Data: \(error)")
            loader?.hide()
            return []
        }
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == movieCollectionView {
            return movieData.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == movieCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
            cell.movieName.text = movieData[indexPath.item].title
            if let movieUrl = movieData[indexPath.item].poster {
                cell.movieImg.kf.setImage(with: URL(string: movieUrl))
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == movieCollectionView {
            let movieDetailVC = MovieDetailViewController(nibName: "MovieDetailViewController", bundle: nil)
            movieDetailVC.movieData = movieData[indexPath.item]
            self.navigationController?.pushViewController(movieDetailVC, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            loadMoreMovies()
        }
    }

    func loadMoreMovies() {
        let offset = movieData.count
        let limit = 8
        let moreMovies = fetchMoviesFromCoreData(offset: offset, limit: limit)
        if !moreMovies.isEmpty {
            movieData.append(contentsOf: moreMovies)
            movieCollectionView.reloadData()
            loader?.hide()
        }
    }
    
    func isOffline() -> Bool {
        return !NetworkMonitor.shared.isConnected
    }
}
