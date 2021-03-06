//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Melanie Chan on 2/20/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int = 0;
    
    let tweetRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tweetRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = tweetRefreshControl
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadTweets()

    }
    
    // get tweets from API
    @objc func loadTweets() {
        
        let apiUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        
        numberOfTweets = 20
        let params = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: apiUrl, parameters: params, success: { ( tweets : [NSDictionary]) in
        
            self.tweetArray.removeAll()
            
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.tweetRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print{"couldn't retrieve tweets"}
        })
    }
    
    // for infinite scroll
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    func loadMoreTweets() {
        let apiUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"

        numberOfTweets = numberOfTweets + 20
        let params = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: apiUrl, parameters: params, success: { ( tweets : [NSDictionary]) in
        
            self.tweetArray.removeAll()
            
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print{"couldn't retrieve tweets"}
        })

    }

    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        
        // go back to landing screen
        self.dismiss(animated: true, completion: nil)
        
        // remember that user logged out
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    // create cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
        
        // get user data
        let user = tweetArray[indexPath.row]["user"] as! Dictionary<String, Any>
        
        cell.usernameLabel.text = user["name"] as? String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as! String
        
        // set image
        let imageUrl = URL(string: (user["profile_image_url_https"]) as! String )
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        // set color of fav button
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        
        // get tweet's ID
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        
        // get retweeted status and set
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)
        
        return cell
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    // rows per section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
