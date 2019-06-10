//
//  AlbumCell.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 30/05/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit


class AlbumCell: UITableViewCell {
    
    @IBOutlet weak var coverActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var createDate: UILabel!
    @IBOutlet weak var size: UILabel!
    
    
    func initCell(album: AlbumVK) {
        
        coverActivityIndicator.startAnimating()
        
        title.text = album.title
        createDate.text = CustomizedDateFormatter.fromDateToString(date: album.createDate)
        size.text = String(album.countOfImage)
        
        NetworkController.downloadImage(from: album.coverURL) { [weak self] image in
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
