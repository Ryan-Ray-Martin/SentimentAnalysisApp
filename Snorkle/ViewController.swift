//
//  ViewController.swift
//  Snorkle
//
//  Created by Ryan Martin.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!

    
    let tweetCount = 100
    
    let sentimentClassifier = TweetSentimentClassifier()
    //let sentimentClassifier2 = TwitterSentiment()
    
    // use swifter, a wrapper to unpack the twitter API
    let swifter =  Swifter(consumerKey: "vRuXAaGx3oszSIl8ZLT3uhPpS", consumerSecret: "LDqVhjWehXVVlHLTJ79xoVS9mv4RdLjuErWvv6Q7NTKodKcuAt")
    

    override func viewDidLoad() {
        super.viewDidLoad()
            
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        
        fetchTweets()
    }
    
    func fetchTweets() {
        
        // if let unwraps the optional so we do not make API request with an empty text
        if let searchText = textField.text {
            
            // use the swifter object to call the search tweet method to retrieve the maximum 100 tweets, and store JSON data in results
            // .extended is an enum that makes API retrieve the tweets non-truncated
            
            swifter.searchTweet(using: searchText, lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
                // print(results)
                
                var tweets = [TweetSentimentClassifierInput]()
                var stringTweets = [String]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string{
                        let littleTweet = String(tweet)
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                        stringTweets.append(littleTweet)
                    }
                }
                
                self.makePrediction(with: tweets, stringTweets: stringTweets)
                
            }) { (error) in
                print("There was an error with the Twitter API Request, \(error)")
            }
        }
        
    }
                
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput], stringTweets: [String]) {
        
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            
            var sentimentScorePos = 0
            var sentimentScoreNeg = 0
            var sentimentScoreNeu = 0
            
            for prediction in predictions {
                let sentiment = prediction.label
                
                if sentiment == "Pos" {
                    sentimentScorePos += 1
                }else if sentiment == "Neg" {
                    sentimentScoreNeg += 1
                }else if sentiment == "Neutral" {
                    sentimentScoreNeu += 1
                }
            }
            
            let sentimentScore = sentimentScorePos - sentimentScoreNeg
            
            let exampleTweet = stringTweets[0]
            
            
            
            updateUI(with: sentimentScore, sentimentScorePos: sentimentScorePos, sentimentScoreNeg: sentimentScoreNeg, sentimentScoreNeu: sentimentScoreNeu, exampleTweet: exampleTweet)
            
            
        } catch {
            print("There was an error in making the predication, \(error)")
        }
        
    }

        

        
    func updateUI(with sentimentScore: Int, sentimentScorePos: Int, sentimentScoreNeg: Int, sentimentScoreNeu: Int, exampleTweet: String) {
        print(sentimentScore)
        sentimentLabel.numberOfLines = 0;
        sentimentLabel.text = "The number of positive tweets is \(sentimentScorePos). The number of negative tweets is \(sentimentScoreNeg). The number of neutral tweets is \(sentimentScoreNeu). The overall sentiment score is \(sentimentScore). \n\n Here is a tweet from the last snorkel: \(exampleTweet)."
        sentimentLabel.isHidden = false

        
    }
    
}



