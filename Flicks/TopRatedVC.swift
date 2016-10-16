//
//  TopRatedVC.swift
//  Flicks
//
//  Created by David Bocardo on 10/16/16.
//  Copyright © 2016 David Bocardo. All rights reserved.
//

import UIKit
import AFNetworking
import FTIndicator

class TopRatedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var moviesTV: UITableView!
    @IBOutlet weak var errorView: UIView!

    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.getMoviesData), for: UIControlEvents.valueChanged)
        moviesTV.insertSubview(refreshControl, at: 0)
        
        moviesTV.dataSource = self
        moviesTV.delegate = self
        
        getMoviesData()
    }
    
    func getMoviesData() -> Void {
        FTIndicator.showProgressWithmessage("Loading...")
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if error != nil {
                FTIndicator.dismissProgress()
                self.errorView.isHidden = false
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.hideErrorView), userInfo: nil, repeats: false)
            } else {
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                        //NSLog("response: \(responseDictionary)")
                        self.movies = responseDictionary["results"] as? [NSDictionary]
                        self.moviesTV.reloadData()
                        self.refreshControl.endRefreshing()
                        FTIndicator.dismissProgress()
                    }
                }
            }
        });
        task.resume()
    }
    
    func hideErrorView() -> Void {
        self.errorView.isHidden = true
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moviesTV.deselectRow(at: indexPath, animated: false)
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
