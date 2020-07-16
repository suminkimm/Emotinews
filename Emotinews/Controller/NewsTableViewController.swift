//
//  NewsTableViewController.swift
//  Twittermenti
//
//  Created by Su Min Kim on 7/14/20.
//  Copyright © 2020 London App Brewery. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class NewsTableViewController: UITableViewController {
    
    var newsTopic: String?
    var headerColor: UIColor?
    var newsArray: [News] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.barTintColor = headerColor
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = newsArray[indexPath.row].title
        cell.detailTextLabel?.text = newsArray[indexPath.row].description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "newsToWeb", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! WebViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.url = newsArray[indexPath.row].url
        }
    }
    
    // MARK: - Fetch News Data
    
    func fetchNews() {
        
        if let topic = newsTopic {
            let url = "https://newsapi.org/v2/everything?q=\(topic)&apiKey=\(Secrets.apikey)"
            
            AF.request(url, method: .get).validate().responseJSON { (response) in
                        
                switch response.result {
                    case .success(let data):
                        let newsJSON: JSON = JSON(data)
    //                    let flowerJSON: JSON = JSON(response.value!)
                        
                        for i in 0..<newsJSON["articles"].count {
                            
                            let news = News(title: newsJSON["articles"][i]["title"].string!, description: newsJSON["articles"][i]["source"]["name"].string!, url: newsJSON["articles"][i]["url"].string!)
                            
                            self.newsArray.append(news)
                        }
                        
                        self.tableView.reloadData()
                
                    default:
                        print("Error fetching flower data.")
                }
            }
        }
    }
}
