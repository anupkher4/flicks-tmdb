//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by Anup Kher on 3/31/17.
//  Copyright © 2017 codepath. All rights reserved.
//

import UIKit
import MBProgressHUD

class MovieDetailsViewController: UIViewController {
    @IBOutlet weak var bigPosterImageView: UIImageView!
    @IBOutlet weak var movieDetailsView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var runningTimeLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var errorView: ErrorView!
    
    let defaults = UserDefaults.standard
    
    var movieId: Int!
    var movie: NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(colorLiteralRed: 239/255.0, green: 203/255.0, blue: 104/255, alpha: 1.0)
        
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height * 1.15
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        
        getMovieDetails(id: movieId)
        
        errorView = ErrorView(frame: CGRect(x: 0, y: 80, width: view.bounds.width, height: 60))
        errorView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        
        view.addSubview(errorView)
        
        errorView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TMDB API Helper Methods
    
    func getMovieDetails(id: Int) {
        let urlString = "https://api.themoviedb.org/3/movie/\(id)?api_key=0bae87a1c2bc3fd65e17a82fec52d5c7&language=en-US"
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) {
            (data, response, error) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let data = data {
                self.errorView.isHidden = true
                if let movie = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    if let posterPath = movie.value(forKeyPath: "poster_path") as? String {
                        let smallImageRequest = URLRequest(url: URL(string: "https://image.tmdb.org/t/p/w45/\(posterPath)")!)
                        let largeImageRequest = URLRequest(url: URL(string: "https://image.tmdb.org/t/p/original/\(posterPath)")!)
                        self.bigPosterImageView.setImageWith(
                            smallImageRequest,
                            placeholderImage: nil,
                            success: { (smallImageRequest, smallImageResponse, smallImage) in
                                self.errorView.isHidden = true
                                if (response != nil) {
                                    self.bigPosterImageView.alpha = 0.0
                                    self.bigPosterImageView.image = smallImage
                                    UIView.animate(
                                        withDuration: 0.3,
                                        animations: {
                                            self.bigPosterImageView.alpha = 1.0
                                    }, completion: { (success) in
                                        self.bigPosterImageView.setImageWith(
                                            largeImageRequest,
                                            placeholderImage: smallImage,
                                            success: { (largeImageRequest, largeImageResponse, largeImage) in
                                                self.errorView.isHidden = true
                                                self.bigPosterImageView.image = largeImage
                                        }, failure: { (request, response, error) in
                                            self.errorView.isHidden = false
                                        })
                                    })
                                } else {
                                    self.bigPosterImageView.image = smallImage
                                }
                        }, failure: { (request, response, error) in
                            self.errorView.isHidden = false
                        })
                    }
                    if let title = movie.value(forKeyPath: "original_title") as? String {
                        self.navigationItem.title = title
                        self.titleLabel.text = title
                    }
                    if let release = movie.value(forKeyPath: "release_date") as? String {
                        self.releaseDateLabel.text = self.getFormattedDate(string: release)
                    }
                    if let score = movie.value(forKeyPath: "vote_average") as? Float {
                        if let percentageScore = Int(exactly: (score / 10.0) * 100.0) {
                            self.scoreLabel.text = "\(percentageScore)%"
                        }
                    }
                    if let running = movie.value(forKeyPath: "runtime") as? Int {
                        let hours = running / 60
                        let minutes = running % 60
                        self.runningTimeLabel.text = "\(hours) hr \(minutes) mins"
                    }
                    if let overview = movie.value(forKeyPath: "overview") as? String {
                        self.overviewLabel.text = overview
                        self.overviewLabel.sizeToFit()
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
    
    func getFormattedDate(string: String) -> String {
        var formattedDate = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar(identifier: .gregorian)
        
        if let date = dateFormatter.date(from: string) {
            let components = calendar.dateComponents([.day, .month, .year], from: date)
            if let day = components.day, let month = components.month, let year = components.year {
                var fullMonth = ""
                switch month {
                case 1:
                    fullMonth = "January"
                case 2:
                    fullMonth = "February"
                case 3:
                    fullMonth = "March"
                case 4:
                    fullMonth = "April"
                case 5:
                    fullMonth = "May"
                case 6:
                    fullMonth = "June"
                case 7:
                    fullMonth = "July"
                case 8:
                    fullMonth = "August"
                case 9:
                    fullMonth = "September"
                case 10:
                    fullMonth = "October"
                case 11:
                    fullMonth = "November"
                case 12:
                    fullMonth = "December"
                default:
                    fullMonth = ""
                }
                
                formattedDate = "\(fullMonth) \(day), \(year)"
            }
        }
        
        return formattedDate
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
