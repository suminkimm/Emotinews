//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var newsButton: UIButton!
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: Secrets.consumerKey, consumerSecret: Secrets.consumerSecret)
    
    let tweetCount = 100

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.backgroundView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        self.sentimentLabel.text = "😐"
        
        self.textField.text = ""
        self.textField.backgroundColor = UIColor.white
        self.textField.textColor = UIColor.black
        self.textField.attributedPlaceholder = NSAttributedString(string: "How do people feel about...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        newsButton.layer.cornerRadius = newsButton.bounds.height/2
        newsButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        newsButton.layer.borderWidth = 3
        newsButton.contentEdgeInsets = UIEdgeInsets(top: 15,left: 20,bottom: 15,right: 20) 
        newsButton.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func predictPressed(_ sender: Any) {
    
        fetchTweets()
        
    }
    
    func fetchTweets() {
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.makePrediction(with: tweets)
                
            }) { (error) in
                print("There was an error with the Twitter API request: \(error)")
            }
        }
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for pred in predictions {
                let sentiment = pred.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            
            updateUI(with: sentimentScore)
            
        } catch {
            print("There was an error with making a prediction: \(error)")
        }
        
    }
    
    func updateUI(with sentimentScore: Int) {
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
            backgroundView.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "☺️"
            backgroundView.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
            backgroundView.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
            backgroundView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "☹️"
            backgroundView.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
            backgroundView.backgroundColor = #colorLiteral(red: 1, green: 0.4451578142, blue: 0.3811807604, alpha: 1)
        } else if sentimentScore <= -20 {
            self.sentimentLabel.text = "🤮"
            backgroundView.backgroundColor = #colorLiteral(red: 0.4560404494, green: 0.3024776616, blue: 0.05991018704, alpha: 1)
        }
        
        newsButton.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NewsTableViewController
        if let searchtext = textField.text {
            destinationVC.newsTopic = searchtext
            destinationVC.headerColor = backgroundView.backgroundColor
        }
    }
}
