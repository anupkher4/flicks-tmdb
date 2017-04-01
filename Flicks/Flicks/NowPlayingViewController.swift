//
//  NowPlayingViewController.swift
//  Flicks
//
//  Created by Anup Kher on 3/31/17.
//  Copyright © 2017 codepath. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class NowPlayingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var nowPlayingTableView: UITableView!
    
    var errorView: ErrorView!
    
    let defaults = UserDefaults.standard
    
    var posterBaseUrl = ""
    var posterSize = ""
    var bigPosterSize = ""
    var movies: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        nowPlayingTableView.insertSubview(refreshControl, at: 0)
        
        nowPlayingTableView.delegate = self
        nowPlayingTableView.dataSource = self
        nowPlayingTableView.rowHeight = 120
        
        getApiConfiguration()
        getNowPlayingMovies()
        
        errorView = ErrorView(frame: CGRect(x: 0, y: 80, width: view.bounds.width, height: 60))
        errorView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        
        view.addSubview(errorView)
        
        errorView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Delegate Methods
    
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
            let urlString = "\(posterBaseUrl)\(posterSize)/\(posterPath)"
            let url = URL(string: urlString)
            cell.posterImageView.setImageWith(url!)
        }
        if let title = movie.value(forKeyPath: "original_title") as? String {
            cell.titleLabel.text = title
        }
        if let overview = movie.value(forKeyPath: "overview") as? String {
            cell.overviewLabel.text = overview
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - TMDB API Helper Methods
    
    func getApiConfiguration() {
        let url = URL(string: "https://api.themoviedb.org/3/configuration?api_key=0bae87a1c2bc3fd65e17a82fec52d5c7")
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) {
            (data, response, error) in
            
            //MBProgressHUD.hide(for: self.view, animated: true)
            
            if let data = data {
                self.errorView.isHidden = true
                if let responseDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    if let images = responseDictionary?.value(forKeyPath: "images") as? NSDictionary {
                        if let baseUrl = images.value(forKeyPath: "secure_base_url") as? String {
                            self.posterBaseUrl = baseUrl
                            if self.defaults.object(forKey: "base_url") == nil {
                                self.defaults.set(baseUrl, forKey: "base_url")
                            }
                        }
                        if let posterSizes = images.value(forKeyPath: "poster_sizes") as? [String] {
                            self.posterSize = posterSizes[0]
                            self.bigPosterSize = posterSizes[4]
                            if self.defaults.object(forKey: "poster_sizes") == nil {
                                self.defaults.set(posterSizes, forKey: "poster_sizes")
                            }
                        }
                    }
                }
            }
            
            if let error = error {
                print(error)
                self.errorView.isHidden = false
            }
        }
        task.resume()
    }
    
    func getNowPlayingMovies(_ refreshControl: UIRefreshControl? = nil) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=0bae87a1c2bc3fd65e17a82fec52d5c7")
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) {
            (data, response, error) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let data = data {
                self.errorView.isHidden = true
                if let responseDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    if let results = responseDictionary?.value(forKeyPath: "results") as? [NSDictionary] {
                        self.movies = results
                        self.nowPlayingTableView.reloadData()
                        
                        if refreshControl != nil {
                            refreshControl!.endRefreshing()
                        }
                    }
                }
            }
            
            if let error = error {
                print(error)
                self.errorView.isHidden = false
            }
        }
        task.resume()
    }
    
    // MARK: - Refresh Control Action
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        getNowPlayingMovies(refreshControl)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieToDetails" {
            let destinationVc = segue.destination as! MovieDetailsViewController
            let indexPath = nowPlayingTableView.indexPath(for: sender as! MovieTableViewCell)
            let selectedMovie = movies[indexPath!.row]
            let id = selectedMovie.value(forKeyPath: "id") as! Int
            
            destinationVc.movieId = id
            //print(id)
        }
    }
    

}
