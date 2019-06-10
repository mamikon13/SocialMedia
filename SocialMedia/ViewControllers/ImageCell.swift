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
    
    
    func initCell(image: ImageVK) {
        
        coverActivityIndicator.startAnimating()
        
        imageText.text = image.text
        loadDate.text = CustomizedDateFormatter.fromDateToString(date: image.loadDate)
        likes.text = String(image.likesCount)
        comments.text = String(image.commentsCount)
        
        NetworkController.downloadImage(from: image.imageSmallURL) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.cover.image = image
                self.coverActivityIndicator.stopAnimating()
            }
        }
    }
    
    
    override func prepareForReuse() {
        cover.image = nil
        super.prepareForReuse()
    }

}
