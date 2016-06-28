//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by keivn c on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

typealias PhotoTakingHelperCallback = UIImage? -> Void

class PhotoTakingHelper: NSObject {
    
    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
    
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback)
    {
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        showPhotoSourceSelection()
    }
    
    
    func showPhotoSourceSelection()
    {
        let alertController = UIAlertController(title: nil, message: "Select a photo from the following", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let phototLibraryAction = UIAlertAction(title: "Photo from library", style: .Default) { (action) in
            self.showImagePickerController(.PhotoLibrary)
        }
        alertController.addAction(phototLibraryAction)
        
        if (UIImagePickerController.isCameraDeviceAvailable(.Rear))
        {
            let cameraAction = UIAlertAction(title: "Photo from camera", style: .Default) { (action) in
                self.showImagePickerController(.Camera)
            }
            alertController.addAction(cameraAction)
        }
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType)
    {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
    }
}


extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
        callback(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
}