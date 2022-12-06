//
//  ViewController.swift
//  ImageDownload
//
//  Created by Aditya on 06/12/22.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet var movieTableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    movieTableView.dataSource = self
    movieTableView.register(
      UINib(nibName: "MovieTableViewCell", bundle: nil),
      forCellReuseIdentifier: "movieTableViewCell"
    )
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return movies.count;
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(
      withIdentifier: "movieTableViewCell",
      for: indexPath
    ) as? MovieTableViewCell {
      let movie = movies[indexPath.row]
      cell.movieTitle.text = movie.title
      cell.movieImage.image = movie.image
      
      if movie.state == .initial {
        cell.loadingIndicator.isHidden = false
        cell.loadingIndicator.startAnimating()
        startDownload(movie: movie, indexPath: indexPath)
      } else {
        cell.loadingIndicator.isHidden = true
        cell.loadingIndicator.stopAnimating()
      }
      
      return cell
    } else {
      return UITableViewCell()
    }
  }

  fileprivate func startDownload(movie: Movie,indexPath: IndexPath) {
    let imageDownloader = ImageDownloader()
    if movie.state == .initial {
      Task {
        do {
          let image = try await imageDownloader.downloadImage(url: movie.poster)
          movie.state = .downloaded
          movie.image = image
          self.movieTableView.reloadRows(at: [indexPath], with: .automatic)
        } catch {
          movie.state = .failed
          movie.image = nil
        }
      }
    }
  }
}
