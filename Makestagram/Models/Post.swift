//
//  Post.swift
//  Makestagram
//
//  Created by keivn c on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond

class Post: PFObject, PFSubclassing {
    
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    var image: Observable<UIImage?> = Observable(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    var likes: Observable<[PFUser]?> = Observable(nil)
    
    static func parseClassName() -> String {
        return "Post"
    }
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    // MARK: upload post
    func uploadPost() {
        if let image = image.value {
            
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            
            user = PFUser.currentUser()
            self.imageFile = imageFile
            
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            saveInBackgroundWithBlock() { (success: Bool, error: NSError?) in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }
    
    // MARK: download images in bg
    func downloadImage () {
        if (image.value == nil) {
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale: 1.0)!
                    self.image.value = image
                }
            }
        }
    }
    
    // MARK: find user's post likes
    func fetchLikes() {
        if likes.value != nil {
            return
        }
        
        ParseHelper.likesForPost(self, completionBlock: { (likes: [PFObject]?, error: NSError?) -> Void in
            let validLikes = likes?.filter {like in like[ParseHelper.ParseLikeFromUser] != nil}
            
            self.likes.value = validLikes?.map { like in let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                return fromUser
            }
        })
    }
    
    // MARK: has user liked a post or not
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    // MARK: set like/unlike button for post
    func toggleLikePost(user: PFUser) {
        if (doesUserLikePost(user)) {
            likes.value = likes.value?.filter {$0 != user}
            ParseHelper.unlikePost(user, post: self)
        } else {
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
}
