//
//  MoviesViewController.swift
//  Flicks
//
//  Created by David Bocardo on 10/15/16.
//  Copyright © 2016 David Bocardo. All rights reserved.
//

import UIKit
import AFNetworking
import FTIndicator

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var moviesTV: UITableView!
    
    var movies: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()

        FTIndicator.showProgressWithmessage("Loading...")
        
        moviesTV.dataSource = self
        moviesTV.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    //NSLog("response: \(responseDictionary)")
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.moviesTV.reloadData()
                    FTIndicator.dismissProgress()
                }
            }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = self.movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = moviesTV.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        let movie = self.movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview

        if let posterPath = movie["poster_path"] as? String {
            let baseURL = "http://image.tmdb.org/t/p/w500"
            let imageURL = URL(string: baseURL + posterPath)
            cell.moviePoster.setImageWith(imageURL!)
        }
        else {
            // No poster image
            cell.moviePoster.image = nil
        }
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailSegue") {
            let detailVC = segue.destination as! MovieDetailVC
            
            if let indexPath = moviesTV.indexPath(for: sender as! UITableViewCell) {
                let movie = self.movies![indexPath.row]
                let movieID = movie["id"] as! Int
                detailVC.movieID = movieID
            }
        }
    }
}
