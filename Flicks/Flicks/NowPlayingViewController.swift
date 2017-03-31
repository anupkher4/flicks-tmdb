//
//  NowPlayingViewController.swift
//  Flicks
//
//  Created by Anup Kher on 3/31/17.
//  Copyright © 2017 codepath. All rights reserved.
//

import UIKit
import AFNetworking

class NowPlayingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var nowPlayingTableView: UITableView!

    var posterBaseUrl = ""
    var posterSize = ""
    var movies: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nowPlayingTableView.delegate = self
        nowPlayingTableView.dataSource = self
        nowPlayingTableView.rowHeight = 120
        
        getApiConfiguration()
        getNowPlayingMovies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        
        let movie = movies[indexPath.row]
        
        if let posterPath = movie.value(forKeyPath: "poster_path") as? String {
            if let image = getMoviePosterImage(baseUrl: posterBaseUrl, size: posterSize, posterPath: posterPath) {
                cell.posterImageView.image = image
            }
        }
        if let title = movie.value(forKeyPath: "original_title") as? String {
            cell.titleLabel.text = title
        }
        if let overview = movie.value(forKeyPath: "overview") as? String {
            cell.overviewLabel.text = overview
        }
        
        return cell
    }
    
    func getApiConfiguration() {
        let url = URL(string: "https://api.themoviedb.org/3/configuration?api_key=0bae87a1c2bc3fd65e17a82fec52d5c7")
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request) {
            (data, response, error) in
            if let data = data {
                if let responseDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    if let images = responseDictionary?.value(forKeyPath: "images") as? NSDictionary {
                        if let baseUrl = images.value(forKeyPath: "secure_base_url") as? String {
                            self.posterBaseUrl = baseUrl
                        }
                        if let posterSizes = images.value(forKeyPath: "poster_sizes") as? [String] {
                            self.posterSize = posterSizes[0]
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func getNowPlayingMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=0bae87a1c2bc3fd65e17a82fec52d5c7")
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request) {
            (data, response, error) in
            if let data = data {
                if let responseDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    if let results = responseDictionary?.value(forKeyPath: "results") as? [NSDictionary] {
                        self.movies = results
                        self.nowPlayingTableView.reloadData()
                    }
                }
            }
        }
        task.resume()
    }
    
    func getMoviePosterImage(baseUrl: String, size: String, posterPath: String) -> UIImage? {
        let urlString = "\(baseUrl)\(size)/\(posterPath)"
        let url = URL(string: urlString)
        if let data = try? Data(contentsOf: url!) {
            if let image = UIImage(data: data) {
                return image
            }
        }
        
        return nil
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
