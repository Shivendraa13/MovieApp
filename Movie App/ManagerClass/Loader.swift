//
//  Loader.swift
//  Movie App
//
//  Created by Shivendra on 26/09/24.
//

import UIKit

class Loader {
    private var loader: UIActivityIndicatorView
    
    init(in view: UIView) {
        loader = UIActivityIndicatorView(style: .large)
        loader.center = view.center
        loader.hidesWhenStopped = true
        view.addSubview(loader)
    }
    
    func show() {
        DispatchQueue.main.async {
            self.loader.startAnimating()
        }
    }
    
    func hide() {
        DispatchQueue.main.async {
            self.loader.stopAnimating()
        }
    }
}
