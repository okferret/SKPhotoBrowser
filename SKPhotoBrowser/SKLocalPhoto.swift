//
//  SKLocalPhoto.swift
//  SKPhotoBrowser
//
//  Created by Antoine Barrault on 13/04/2016.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

// MARK: - SKLocalPhoto
open class SKLocalPhoto: NSObject, SKPhotoProtocol {
    
    open var underlyingImage: UIImage!
    open var photoURL: String!
    open var contentMode: UIView.ContentMode = .scaleToFill
    open var shouldCachePhotoURLImage: Bool = false
    open var caption: String?
    open var index: Int = 0
    
    override init() {
        super.init()
    }
    
    convenience init(url: String) {
        self.init()
        photoURL = url
    }
    
    convenience init(url: String, holder: UIImage?) {
        self.init()
        photoURL = url
        underlyingImage = holder
    }
    
    open func checkCache() {}
    
    open func loadUnderlyingImageAndNotify() {
        // Already has an image and no remote/local path to load from
        if underlyingImage != nil && photoURL == nil {
            loadUnderlyingImageComplete()
            return
        }

        guard let photoURL = photoURL else {
            loadUnderlyingImageComplete()
            return
        }

        // Load the image from disk on a background queue to avoid blocking the main thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var loadedImage: UIImage?
            if FileManager.default.fileExists(atPath: photoURL),
               let data = FileManager.default.contents(atPath: photoURL) {
                loadedImage = UIImage(data: data)
            }

            DispatchQueue.main.async {
                if let image = loadedImage {
                    self.underlyingImage = image
                }
                // Notify only once, after we know whether loading succeeded or failed
                self.loadUnderlyingImageComplete()
            }
        }
    }
    
    open func loadUnderlyingImageComplete() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION), object: self)
    }
    
    // MARK: - class func
    open class func photoWithImageURL(_ url: String) -> SKLocalPhoto {
        return SKLocalPhoto(url: url)
    }
    
    open class func photoWithImageURL(_ url: String, holder: UIImage?) -> SKLocalPhoto {
        return SKLocalPhoto(url: url, holder: holder)
    }
}
