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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        // Do any additional setup after loading the view.
    }

    func takePhoto()
    {
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            print("received callback")
            if let image = image {
                let imageData = UIImageJPEGRepresentation(image, 0.8)!
                let imageFile = PFFile(name: "image", data: imageData)!
                
                let post = PFObject(className: "Post")
                post["imageFile"] = imageFile
                post.saveInBackground()
            }
        }
    }
}

extension TimelineViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool
    {
        if (viewController is PhotoViewController)
        {
            takePhoto()
            return false
        }
        else
        {
            return true
        }
    }
}
