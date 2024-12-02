//
//  MovieListVM.swift
//  Movie App
//
//  Created by Shivendra on 25/09/24.
//

import Foundation

class MovieListVM {
    
    var didFetchMovies: (() -> Void)?
    var notFetchMovies: (() -> Void)?
    
    func fetchMovies(completion: @escaping (Result<[MovieResModel], Error>) -> Void) {
        
        guard let url = URL(string: "https://freetestapi.com/api/v1/movies") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let movieResponse = try JSONDecoder().decode([MovieResModel].self, from: data)
                completion(.success(movieResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
