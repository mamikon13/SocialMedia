//
//  ImageCell.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 09/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit


class ImageCell: UITableViewCell {
    
    @IBOutlet weak var coverActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var imageText: UILabel!
    @IBOutlet weak var loadDate: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var comments: UILabel!
    
    var task: URLSessionTask?
    
    
    func initCell(image: ImageVK) {
        
        coverActivityIndicator.startAnimating()
        
        imageText.text = image.text
        loadDate.text = String(date: image.loadDate)
        likes.text = String(image.likesCount)
        comments.text = String(image.commentsCount)
        
        task = NetworkController.downloadImage(from: image.imageSmallURL) { [cover, coverActivityIndicator] image in
            DispatchQueue.main.async {
                cover?.image = image
                coverActivityIndicator?.stopAnimating()
            }
        }
    }
    
    
    override func prepareForReuse() {
        cover.image = nil
        task?.cancel()
        super.prepareForReuse()
    }

}
