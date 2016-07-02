//
//  FriendSearchViewController.swift
//  Makestagram
//
//  Created by keivn c on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

class FriendSearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var users: [PFUser]?
    
    // setup local cache, update UI immediately
    
    var followingUsers: [PFUser]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var query: PFQuery? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    enum State {
        case DefaultMode, SearchMode
    }
    
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode :
                query = ParseHelper.allUsers(updateList)
            case .SearchMode :
                let searchText = searchBar?.text ?? ""
                query = ParseHelper.searchUsers(searchText, completionBlock: updateList)
            }
        }
    }
    
    // MARK: update user list
    func updateList(results: [PFObject]?, error: NSError?) {
        self.users = results as? [PFUser] ?? []
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        state = .DefaultMode
        // fill cache with users following
        ParseHelper.getFollowingUsersForUser(PFUser.currentUser()!){ (results: [PFObject]?, error: NSError?) -> Void in
            let relations = results ?? []
            self.followingUsers = relations.map {
                $0.objectForKey(ParseHelper.ParseFollowToUser) as! PFUser
            }
        }
    }
}

// MARK: table view data source
extension FriendSearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! FriendSearchTableViewCell
        let user = users![indexPath.row]
        cell.user = user
        
        if let followingUsers = followingUsers {
            cell.canFollow = !followingUsers.contains(user)
        }
        
        cell.delegate = self
        return cell
    }
}

// MARK: search bar delegate
extension FriendSearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        ParseHelper.searchUsers(searchText, completionBlock: updateList)
    }
}

extension FriendSearchViewController: FriendSearchTableViewCellDelegate {
    
    func cell(cell: FriendSearchTableViewCell, didSelectFollowUser user: PFUser) {
        ParseHelper.addFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
        followingUsers?.append(user)
    }
    
    func cell(cell: FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser) {
        if let followingUsers = followingUsers {
            ParseHelper.deleteFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
            self.followingUsers = followingUsers.filter({$0 != user})
        }
    }
}
