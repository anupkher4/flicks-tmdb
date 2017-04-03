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

class NowPlayingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var nowPlayingTableView: UITableView!
    @IBOutlet weak var nowPlayingCollectionView: UICollectionView!
    
    var errorView: ErrorView!
    
    let defaults = UserDefaults.standard
    
    var endpoint = "now_playing"
    var movies: [NSDictionary] = []
    var searchedMovies: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(colorLiteralRed: 239/255.0, green: 203/255.0, blue: 104/255, alpha: 1.0)
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor(colorLiteralRed: 239/255.0, green: 203/255.0, blue: 104/255, alpha: 1.0)
            navigationBar.tintColor = UIColor(white: 0.0, alpha: 1.0)
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        nowPlayingTableView.insertSubview(refreshControl, at: 0)
        
        nowPlayingTableView.delegate = self
        nowPlayingTableView.dataSource = self
        nowPlayingTableView.rowHeight = 120
        nowPlayingTableView.backgroundColor = UIColor(colorLiteralRed: 239/255.0, green: 203/255.0, blue: 104/255, alpha: 1.0)
        
        nowPlayingCollectionView.delegate = self
        nowPlayingCollectionView.dataSource = self
        nowPlayingCollectionView.isHidden = true
        nowPlayingCollectionView.backgroundColor = UIColor(colorLiteralRed: 239/255.0, green: 203/255.0, blue: 104/255, alpha: 1.0)
        
        getNowPlayingMovies()
        
        errorView = ErrorView(frame: CGRect(x: 0, y: 80, width: view.bounds.width, height: 60))
        errorView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        
        view.addSubview(errorView)
        
        errorView.isHidden = true
        
        let listGridSegment = UISegmentedControl(frame: CGRect(x: view.bounds.width - 100, y: view.bounds.height - 100, width: 80, height: 40))
        listGridSegment.backgroundColor = UIColor(colorLiteralRed: 239/255.0, green: 203/255.0, blue: 104/255, alpha: 1.0)
        listGridSegment.tintColor = UIColor.black
        listGridSegment.insertSegment(with: UIImage(named: "list_view"), at: 0, animated: true)
        listGridSegment.insertSegment(with: UIImage(named: "grid_view"), at: 1, animated: true)
        listGridSegment.selectedSegmentIndex = 0
        
        listGridSegment.addTarget(self, action: #selector(segmentTapped(sender:)), for: .valueChanged)
        
        view.addSubview(listGridSegment)
        
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 20, height: 30))
        searchBar.placeholder = "Search for movies"
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = true
        navigationItem.titleView = searchBar
    }

    func segmentTapped(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            nowPlayingCollectionView.isHidden = true
            nowPlayingTableView.isHidden = false
        }
        if sender.selectedSegmentIndex == 1 {
            nowPlayingTableView.isHidden = true
            nowPlayingCollectionView.isHidden = false
        }
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
        return searchedMovies.count == 0 ? movies.count : searchedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        cell.selectionStyle = .gray
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cell.backgroundColor = UIColor(colorLiteralRed: 239/255.0, green: 203/255.0, blue: 104/255, alpha: 1.0)
        
        var movie: NSDictionary = [:]
        
        if searchedMovies.count == 0 {
            movie = movies[indexPath.row]
        } else {
            movie = searchedMovies[indexPath.row]
        }
        
        if let posterPath = movie.value(forKeyPath: "poster_path") as? String {
            let urlString = "https://image.tmdb.org/t/p/w342/\(posterPath)"
            let imageRequest = URLRequest(url: URL(string: urlString)!)
            cell.posterImageView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (request, response, image) in
                    self.errorView.isHidden = true
                    
                    // If image is not cached
                    if (response != nil) {
                        cell.posterImageView.alpha = 0.0
                        cell.posterImageView.image = image
                        UIView.animate(withDuration: 0.3) {
                            cell.posterImageView.alpha = 1.0
                        }
                    } else { // If image is cached, set it
                        cell.posterImageView.image = image
                    }
                },
                failure: { (request, response, error) in
                    self.errorView.isHidden = false
                })
        }
        if let title = movie.value(forKeyPath: "original_title") as? String {
            cell.titleLabel.text = title
        }
        if let overview = movie.value(forKeyPath: "overview") as? String {
            cell.overviewLabel.text = overview
            cell.overviewLabel.sizeToFit()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Collection View Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedMovies.count == 0 ? movies.count : searchedMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        cell.backgroundColor = UIColor(colorLiteralRed: 239/255.0, green: 203/255.0, blue: 104/255, alpha: 1.0)
        
        var movie: NSDictionary = [:]
        
        if searchedMovies.count == 0 {
            movie = movies[indexPath.row]
        } else {
            movie = searchedMovies[indexPath.row]
        }
        
        if let posterPath = movie.value(forKeyPath: "poster_path") as? String {
            let urlString = "https://image.tmdb.org/t/p/w342/\(posterPath)"
            let imageRequest = URLRequest(url: URL(string: urlString)!)
            cell.posterImageView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (request, response, image) in
                    self.errorView.isHidden = true
                    
                    // If image is not cached
                    if (response != nil) {
                        cell.posterImageView.alpha = 0.0
                        cell.posterImageView.image = image
                        UIView.animate(withDuration: 0.3) {
                            cell.posterImageView.alpha = 1.0
                        }
                    } else { // If image is cached, set it
                        cell.posterImageView.image = image
                    }
                },
                failure: { (request, response, error) in
                    self.errorView.isHidden = false
                })
        }
        if let title = movie.value(forKeyPath: "original_title") as? String {
            cell.titleLabel.text = title
            cell.titleLabel.sizeToFit()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "movieToDetails", sender: collectionView.cellForItem(at: indexPath))
    }
    
    // MARK: - TMDB API Helper Methods
    
    func getNowPlayingMovies(_ refreshControl: UIRefreshControl? = nil) {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=0bae87a1c2bc3fd65e17a82fec52d5c7")
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
                        self.nowPlayingCollectionView.reloadData()
                        
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
    
    func searchMovies(withKeyword searchString: String) {
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=0bae87a1c2bc3fd65e17a82fec52d5c7&include_adult=false&query=\(searchString)"
        let queryString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: queryString!)
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let data = data {
                self.errorView.isHidden = true
                if let responseDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    if let results = responseDictionary?.value(forKeyPath: "results") as? [NSDictionary] {
                        self.searchedMovies = results
                        self.nowPlayingTableView.reloadData()
                        self.nowPlayingCollectionView.reloadData()
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
            
            var indexPath: IndexPath = IndexPath()
            
            if sender is MovieTableViewCell {
                indexPath = nowPlayingTableView.indexPathForSelectedRow!
            } else if sender is MovieCollectionViewCell {
                let cell = sender as! MovieCollectionViewCell
                indexPath = nowPlayingCollectionView.indexPath(for: cell)!
            }
            
            var selectedMovie: NSDictionary = [:]
            
            if searchedMovies.count == 0 {
                selectedMovie = movies[indexPath.row]
            } else {
                selectedMovie = searchedMovies[indexPath.row]
            }
            
            let id = selectedMovie.value(forKeyPath: "id") as! Int
            
            destinationVc.movieId = id
            
            searchedMovies = []
            nowPlayingTableView.reloadData()
            nowPlayingCollectionView.reloadData()
        }
    }
    

}

extension NowPlayingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.size.width
        let numberOfItemsPerRow = 3
        let dimensions = CGFloat(Int(totalWidth) / numberOfItemsPerRow)
        
        return CGSize(width: dimensions, height: 200)
    }
}

extension NowPlayingViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            print("Searching for movie titles containing \(searchBar.text!)")
            searchMovies(withKeyword: searchBar.text!)
            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchedMovies = []
        nowPlayingTableView.reloadData()
        nowPlayingCollectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}
