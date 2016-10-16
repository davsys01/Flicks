//
//  MovieDetailVC.swift
//  Flicks
//
//  Created by David Bocardo on 10/15/16.
//  Copyright © 2016 David Bocardo. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailVC: UIViewController {

    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieTagline: UILabel!
    @IBOutlet weak var movieReleaseDate: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    
    var movieID: Int!
    var movie: NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(String(movieID))?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    self.movie = responseDictionary as NSDictionary
                    
                    self.movieTitle.text = self.movie?["title"] as? String
                    self.movieTagline.text = self.movie?["tagline"] as? String
                    self.movieReleaseDate.text = self.movie?["release_date"] as? String
                    self.movieOverview.text = self.movie?["overview"] as? String
                    self.movieOverview.sizeToFit()
                    if let posterPath = self.movie?["poster_path"] as? String {
                        let baseURL = "http://image.tmdb.org/t/p/w500"
                        let imageURL = URL(string: baseURL + posterPath)
                        self.posterImage.setImageWith(imageURL!)
                    }
                    else {
                        // No poster image
                        self.posterImage.image = nil
                    }
                }
            }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
