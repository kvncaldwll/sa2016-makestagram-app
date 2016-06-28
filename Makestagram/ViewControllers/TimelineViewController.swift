//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by keivn c on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController {
    
    var photoTakingHelper: PhotoTakingHelper?
    @IBOutlet weak var tableView: UITableView!
    var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        // Do any additional setup after loading the view.
    }

    func takePhoto() {
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            let post = Post()
            post.image = image
            post.uploadPost()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        
        query.includeKey("user")
        query.orderByAscending("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (result: [PFObject]?, error: NSError?) -> Void in
            self.posts = result as? [Post] ?? []
            
            for post in self.posts {
                do {
                    let data = try post.imageFile?.getData()
                    post.image = UIImage(data: data!, scale: 1.0)
                } catch {
                    print("could not fetch image")
                }
            }
            
            self.tableView.reloadData()
        }
    }
}

extension TimelineViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            takePhoto()
            return false
        } else {
            return true
        }
    }
}

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        cell.postImageView.image = posts[indexPath.row].image
        return cell
    }
}
